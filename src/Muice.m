classdef Muice < handle
    %MUICE Service lookup framework for Matlab
    %   Using function handles, dependency injection at the function level.
    %   Can also be used as a global key-value store
    
    properties(Access=private)
        FunctionMappings;
        ValueMappings;
    end
    
    methods(Static)
        % Singleton implementation
        function obj = instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = Muice();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
      
        % Public static versions that shadow the "real" versions.
        % This way the user doesn't have to call .instance on everything
        function bindFunction(identifier, handle, options)
            if(nargin < 3)
                options = struct();
            end
            Muice.instance.bindFunction2(identifier, handle, options);
        end
        
        function handle = injectFunction(identifier)
            handle = Muice.instance.injectFunction2(identifier);
        end
        
        function bindValue(identifier, value, options)
            if(nargin < 3)
                options = struct();
            end
            Muice.instance.bindValue2(identifier, value, options);
        end
        
        function value = injectValue(identifier)
            value = Muice.instance.injectValue2(identifier);
        end
        
        function clearBindings()
            Muice.instance.clearBindings2();
        end
        
        % These three do not shadow real versions, but are built on top of
        % the other public static methods
        function returnVal = bindValueAndOutput(identifier, value, returnVal)
            Muice.bindValue(identifier, value);
        end
        
        function bindMultipleValues(varargin)
            nargin = size(varargin,2);
            npairs = nargin / 2;
            
            for i = 1:npairs
                identifier = varargin{i*2 - 1};
                value = varargin{i*2};
                Muice.bindValue(identifier, value);
            end
        end
        
        function returnVal = bindMultipleValuesAndOutput(varargin)
            % Pop off returnVal from the end of the list
            nargin = size(varargin,2);
            returnVal = varargin{nargin};
            nargin = nargin - 1;
            
            npairs = nargin / 2;
            
            for i = 1:npairs
                identifier = varargin{i*2 - 1};
                value = varargin{i*2};
                Muice.bindValue(identifier, value);
            end
        end
    end
    
    methods(Access=private)
        function this = Muice()
            this.FunctionMappings = struct('identifier', {}, 'handle', {});
            this.ValueMappings = struct('identifier', {}, 'value', {});
        end
        
        % Bind a function handle to an identifier
        function bindFunction2(this, identifier, handle, options)
            if(~isa(handle,'function_handle'))
                throw(MException('Muice:InvalidHandle', 'handle argument is not a function_handle'));
            end
            if(nargin < 3)
                options = struct();
            end
            
            % check if we already have a mapping
            currentIndex = Muice.indexOfMapping(identifier, this.FunctionMappings);
            if(isempty(currentIndex))
                % no existing match, add to the end
                index = Muice.nextIndex(this.FunctionMappings);
                this.FunctionMappings(index).identifier = identifier;
                this.FunctionMappings(index).handle = handle;
            else
                % already have a match, so check if we allow overwriting it
                if(isfield(options, 'overwrite') && options.overwrite == true)
                    this.FunctionMappings(currentIndex).handle = handle;
                else
                    error('Muice:DuplicateIdentifier', 'identifier ''%s'' already exists in FunctionMappings', identifier);
                end
            end
        end
        
        % Retrieve the bound handle for an identifier
        % If no match is found, try to resolve using Matlab's path
        function handle = injectFunction2(this, identifier)
            % Look for a matching identifier in the FunctionMappings array.
            index = Muice.indexOfMapping(identifier, this.FunctionMappings);

            % If we found a match, return that
            if(~isempty(index))
                entry = this.FunctionMappings(index);
                handle = entry.handle;
            % If we didn't find a match, try to create a function handle
            % using Matlab's path resolution
            else
                handle = str2func(identifier);
            end
        end
        
        % Bind a value to an identifier
        function bindValue2(this, identifier, value, options)
            if(isa(value,'function_handle'))
                throw(MException('Muice:InvalidValue', 'value argument is a function_handle'));
            end
            if(nargin < 3)
                options = struct();
            end
            
            % check if we already have a mapping
            currentIndex = Muice.indexOfMapping(identifier, this.ValueMappings);
            if(isempty(currentIndex))
                % no existing match, add to the end
                index = Muice.nextIndex(this.ValueMappings);
                this.ValueMappings(index).identifier = identifier;
                this.ValueMappings(index).value = value;
            else
                % already have a match, so check if we allow overwriting it
                if(isfield(options, 'overwrite') && options.overwrite == true)
                    this.ValueMappings(currentIndex).value = value;
                else
                    error('Muice:DuplicateIdentifier', 'identifier ''%s'' already exists in ValueMappings', identifier);
                end
            end
        end
        
        % Retrieve the bound value for an identifier
        % If no match is found, return []
        function value = injectValue2(this, identifier)
            % Look for a matching identifier in the ValueMappings array.
            index = Muice.indexOfMapping(identifier, this.ValueMappings);
            
            % If we found a match, return that
            if(~isempty(index))
                entry = this.ValueMappings(index);
                value = entry.value;
            else
            % if we didn't find a match, return empty
                value = [];
            end
        end
        
        % Clear all stored bindings
        function clearBindings2(this)
            this.FunctionMappings = struct('identifier', {}, 'handle', {});
            this.ValueMappings = struct('identifier', {}, 'value', {});
        end
    end
    
    methods (Static, Access = private)
        function index = nextIndex(array)
            % we only want to operate on vectors, not matrices.
            % if both m and n are greater than 1, throw exception
            [m n] = size(array);
            if(m > 1 && n > 1)
                throw(MException('Muice:DimensionMismatch', 'm=%d, n=%d', m, n));
            end
            
            currentLength = length(array);
            index = currentLength + 1;
        end
        
        function index = indexOfMapping(identifier, mappings)
            % Iterate through mappings array, looking for a
            % matching identifier. If we find one, return the index
            index = [];
            for(i = 1:length(mappings))
                entry = mappings(i);
                if(strcmp(entry.identifier, identifier))
                    index = i;
                    break;
                end
            end
            % if we didn't find a match, return the initial [] value
        end
    end
end
