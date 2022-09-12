local Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

return Protect