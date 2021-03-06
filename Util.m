classdef Util
    % Util: Utility functions for export of matrices and vectors to files
    %
    % @docupdate
    %
    % @author Daniel Wirtz @date 2013-07-23
    %
    % @new{0,7,dw,2013-07-23} Added this class.
    %
    % This class is part of the framework
    % KerMor - Model Order Reduction using Kernels:
    % - \c Homepage http://www.morepas.org/software/index.html
    % - \c Documentation http://www.morepas.org/software/kermor/index.html
    % - \c License @ref licensing
    
    properties(Constant)
        % The machine format (little/big endian, 32/64bit) to use upon export.
        %
        % @default ieee-be (Big Endian, as Java implements it)
        %
        % See 'doc fopen' for more details.
        MachineFormat = 'ieee-be';
    end
    
    methods(Static)
        function saveRealMatrix(mat, file, folder)
            % Stores a real double matrix in little endian format.
            %
            % The first 64bits are used to encode the row and column numbers as int32, then the next
            % bytes contain rows*cols*8bytes of double values.
            % The matrix is addressed linearly in a row-wise fashion, i.e. first row, second row ...
            if ~isreal(mat)% || ~ismatrix(mat)
                error('Matrix must contain only real values');
            end
            prec = class(mat);
            % single precision is encoded as float32
            if strcmp(prec,'single')
                prec = 'float32';
            end
            
            if nargin == 3
                if exist(folder,'dir') ~= 7
                    error('Directory "%s" does not exist.', folder);
                end
                file = fullfile(folder,file);
            end
            
            f = fopen(file,'w+',Util.MachineFormat);
            try
                [n,m] = size(mat);
                if n > intmax('int32') || m > intmax('int32')
                    error('Cannot save matrix: Dimensions exceed max int32 value.');
                end
                fwrite(f,n,'int32');
                fwrite(f,m,'int32');
                % Matlab Rev. 2009a: entries are written in column order, which must be transposed
                % in order to read them in row order (native storage format in java
                % apache.commons.math
                fwrite(f,mat',prec);
            catch ME
                fclose(f);
                rethrow(ME);
            end
            fclose(f);
        end
        
        function saveRealVector(vec, file, folder)
            % Stores a real double vector in little endian format.
            %
            % The first 64bits are used to encode the vector size as int32, then the next
            % bytes contain size*8bytes of double values.
            if ~isreal(vec) || ~isvector(vec)
                error('vec must be a vector with real values');
            end
            prec = class(vec);
            % single precision is encoded as float32
            if strcmp(prec,'single')
                prec = 'float32';
            end
            
            if nargin == 3
                if exist(folder,'dir') ~= 7
                    error('Directory "%s" does not exist.', folder);
                end
                file = fullfile(folder,file);
            end
            
            f = fopen(file,'w+',Util.MachineFormat);
            try
                s = length(vec);
                if s > intmax('int32')
                    error('Cannot save vector: Dimension exceeds max int32 value.');
                end
                fwrite(f,s,'int32');
                fwrite(f, vec, prec);
            catch ME
                fclose(f);
                rethrow(ME);
            end
            fclose(f);
        end
        
        function jsonobj = matrixToJSON(value)
            % Takes a matrix and returns a JSON representation as
            % JSONObject with the fields "dim" and "values".
            %
            % The elements are stored inside the values array as double
            % values, iterating through the (multi-dimensional) matrix in
            % the order of the dimensions given in "dim". For a simple
            % matrix this is a column-wise from left to right storage.
            %
            % Parameters:
            % value: A double matrix @type double
            %
            % Return values:
            % jsonobj: A string representation of a JSON object @type char
            siz = sprintf('%d, ',size(value));
            vals = sprintf('%.16e, ',value(:));
            jsonobj = sprintf('{"dim":[%s], "values":[%s]}',siz(1:end-2),vals(1:end-2));
        end
    end
    
end