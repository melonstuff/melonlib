----
---- An A* Promise implementation written by jackkdev (https://github.com/jackkdev) for use in MelonLib.
----

local PromiseError
do
    PromiseError = {}
    PromiseError.__index = PromiseError

    PromiseError.Kind = {
        EXECUTION_ERROR = "EXECUTION_ERROR",
    }

    function PromiseError:_Init(options)
        self.error = tostring(options.error) or "[N/A]"
        self.trace = options.trace
        self.context = options.context
        self.parent = options.parent
        self.created_tick = os.clock()
        self.created_trace = debug.traceback()
    end

    function PromiseError:Extend(options)
        options = options or {}
        options.kind = options.kind or self.kind
        options.parent = self
        return PromiseError.New(options)
    end

    function PromiseError:__tostring()
        return self.error
    end
    
    function melon.IsPromiseError(other)
        return type(other) == "table" and getmetatable(other) == PromiseError
    end

    function melon.PromiseError(options)
        local o = {}
        setmetatable(o, PromiseError)
        o:_Init(options)
        return o
    end
end

local Promise
do
    Promise = {}
    Promise.__index = Promise

    Promise.Status = {
        STARTED = "STARTED",
        RESOLVED = "RESOLVED",
        REJECTED = "REJECTED",
        CANCELLED = "CANCELLED",
    }

    local function RunExecutor(traceback, callback, ...)
        return melon.XPack(xpcall(callback, function(err)
            if istable(err) then 
                return err
            end

            local real_error = melon.PromiseError({
                error = err,
                kind = PromiseError.Kind.EXECUTION_ERROR,
                trace = debug.traceback(tostring(err), 2),
                context = "Promise created at:\n\n" .. (traceback and traceback or ""),
            })

            return real_error
        end, ...))
    end

    local function CreateAdvancer(traceback, callback, resolve, reject)
        return function(...)
            local ok, resultLength, result = RunExecutor(traceback, callback, ...)

            if ok then
                resolve(unpack(result, 1, resultLength))
            else
                reject(result[1])
            end
        end
    end

    --- @brief Marks the Promise as cancelled, and cancels all consuming Promises.
    function Promise:Cancel()
        if self._status ~= Promise.Status.STARTED then
            return
        end

        self._status = Promise.Status.CANCELLED

        if self._cancel_hook then
            self._cancel_hook()
        end

        if self._parent then
            self._parent:_ConsumerCancelled(self)
        end

        for _, child in pairs(self._consumers) do
            child:Cancel()
        end

        self:_Finalize()
    end

    --- @brief Attaches a success/and or failure handler.
    function Promise:Next(success_handler, failure_handler)
        return self:_Next(debug.traceback("", 2), success_handler, failure_handler)
    end

    --- Internal functions.
    do
        function Promise:_Resolve(...)
            if self._status ~= Promise.Status.STARTED then
                if melon.IsPromise((...)) then
                    (...):_ConsumerCancelled(self)
                end
                return
            end

            if melon.IsPromise((...)) then
                local chained = ...

                local promise = chained:Next(function(...)
                    self:_Resolve(...) 
                end, function(...)
                    local err = chained._values[1] 

                    if melon.IsPromiseError(err) and err.kind == PromiseError.Kind.EXECUTION_ERROR then
                        return self:_Reject(err:Extend({
                            error = "The Promise was chained to a Promise that errored.",
                            trace = "",
                            context = string.format(
                                "The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
                                self._source
                            ),
                        }))
                    end

                    self:_Reject(...)
                end)

                if promise._status == Promise.Status.CANCELLED then
                    self:Cancel()
                elseif promise._status == Promise.Status.STARTED then
                    self._parent = promise
                    promise._consumers[self] = true
                end

                return
            end

            self._status = Promise.Status.RESOLVED
            self._n_values, self._values = melon.Pack(...)

            for _, callback in ipairs(self._resolve_hooks) do
                callback(...)
            end

            self:_Finalize()
        end

        function Promise:_Reject(...)
            if self._status ~= Promise.Status.STARTED then
                return
            end

            self._status = Promise.Status.REJECTED
            self._n_values, self._values = melon.Pack(...)

            for _, callback in ipairs(self._reject_hooks) do
                callback(...)
            end
        end

        function Promise:_Finalize()
            for _, callback in ipairs(self._finally_hooks) do
                callback(self._status)
            end

            self._finally_hooks = nil
            self._reject_hooks = nil
            self._resolve_hooks = nil
            self._parent = nil
            self._consumers = nil
        end

        function Promise:_ConsumerCancelled(consumer)
            if self._status ~= Promise.Status.STARTED then
                return
            end

            self._consumers[consumer] = nil

            if next(self._consumers) == nil then
                self:Cancel()
            end
        end

        function Promise:_Next(traceback, success_handler, failure_handler)
            if self._status == Promise.Status.CANCELLED then
                local promise = Promise.New(function() end)
                promise:Cancel()

                return promise
            end

            return melon.PromiseWithTraceback(traceback, function(resolve, reject, on_cancel)
                local success_callback = resolve
                if success_handler then
                    success_callback = CreateAdvancer(traceback, success_handler, resolve, reject)
                end

                local failure_callback = reject
                if failure_handler then
                    failure_callback = CreateAdvancer(traceback, failure_handler, resolve, reject)
                end

                if self._status == Promise.Status.STARTED then
                    local si = table.insert(self._resolve_hooks, success_callback)
                    local fi = table.insert(self._reject_hooks, failure_callback)

                    on_cancel(function()
                        if self._status == Promise.Status.STARTED then
                            table.remove(self._resolve_hooks, si)
                            table.remove(self._reject_hooks, fi)
                        end
                    end)
                elseif self._status == Promise.Status.RESOLVED then
                    success_callback(unpack(self._values, 1, self._n_values))
                elseif self._status == Promise.Status.REJECTED then
                    failure_callback(unpack(self._values, 1, self._n_values))
                end
            end)
        end
    end

    function melon.IsPromise(other)
        return type(other) == "table" and getmetatable(other) == Promise
    end

    function melon.PromiseWithTraceback(traceback, executor, parent)
        local o = {
            _source = traceback,
            _parent = parent,
            _status = Promise.Status.STARTED,
            _values = nil,
            _n_values = -1,
            _resolve_hooks = {},
            _reject_hooks = {},
            _finally_hooks = {},
            _cancel_hook = nil,
            _consumers = setmetatable({}, { __mode = "k" }),
        }
        setmetatable(o, Promise)

        -- Mark ourselves as a consumer on the parent for cancellation propagation.
        if parent and parent._status == Promise.Status.STARTED then
            parent._consumers[o] = true
        end

        -- Call the `executor` functin.
        do
            local function resolve(...)
                o:_Resolve(...)
            end

            local function reject(...)
                o:_Reject(...)
            end

            local function on_cancel(fn)
                if fn then
                    if o._status == Promise.Status.CANCELLED then
                        fn()
                    else
                        o._cancel_hook = fn
                    end
                end

                return o._status == Promise.Status.CANCELLED
            end

            local ok, _, result = RunExecutor(o._source, executor, resolve, reject, on_cancel)

            if not ok then
                reject(result[1])
            end
        end

        return o
    end

    function melon.Promise(executor)
        return melon.PromiseWithTraceback(debug.traceback("", 2), executor)
    end

    function melon.All(promises)
        local results = {}
        local pending = #promises
        local method = "resolve"

        return melon.Promise(function(resolve, reject, on_cancel)
            local function handler(i, resolved)
                return function(...)
                    if not resolved then
                        method = "reject"
                    end

                    pending = pending - 1

                    results[i] = select("#", ...) > 1 and { ... } or ...

                    if pending == 0 then
                        if method == "resolve" then
                            resolve(results)
                        else
                            reject(results)
                        end
                    end

                    return ...
                end
            end

            for i = 1, pending do
                promises[i]:Next(handler(i, true), handler(i, false))
            end

            on_cancel(function()
                for _, promise in ipairs(promises) do
                    promise:Cancel()
                end
            end)
        end)
    end
end