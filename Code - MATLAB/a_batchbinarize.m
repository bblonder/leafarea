function [] = a_batchbinarize(directory, extension, fillholes, largestonly, threshfactor)
    % directory
    % indicates folder in which images should be found - must end in
    % trailing slash
    
    % extension - three-character extension used to subset files in
    % 'directory'. Should not include a preceding '.'.
    
    % if fillholes=1 (default)
    % code fills in interior regions, e.g. herbivorized holes
    
    % if largestonly=1 (default)
    % code retains only the largest connected component, e.g. not all
    % segments of disconnected leaves
    
    % threshfactor (default=1)
    % determines the factor by which to multiply the automatic Otsu 
    % threshold used for binarizing each image. If a scalar, repeated
    % for all iamges; if a vector of length equal to the number of images
    % to be analyzed, values are used in order. Defaults to 1 (exact value
    % of automatic threshold used)
    
    if(directory(length(directory)) ~= '/')
        error('Directory name must end in trailing slash');
    end

    files = dir([directory sprintf('*%s', extension)]);

    numFiles = numel(files);

    
    if (nargin < 3)
        fillholes = 1;
    end
    
    if (nargin < 4)
        largestonly = 1;
    end
    
    if (nargin < 5)
        threshfactor = ones([1 numFiles]);
    else
        if (length(threshfactor)==1)
            threshfactor = repmat(threshfactor, [1 numFiles]);
        end
    end

    for k = 1:numFiles
        filename = [directory files(k).name];
        image = imread(filename);
        
        y = im2bw(image, threshfactor(k) * graythresh(image));
        
        if (fillholes==1)
            z = imfill(~y,'holes');
        else
            z = ~y;
        end
        
        z = bwmorph(z, 'open');
        
        CC = bwconncomp(z);
        
        % choose the largest
        if (largestonly==1)
            numPixels = cellfun(@numel,CC.PixelIdxList);
            [~,idx] = max(numPixels);

            ztrim = false(size(z));
            ztrim(CC.PixelIdxList{idx}) = 1;
        else
            ztrim = z;
        end

        imwrite(ztrim, [filename(1:(end-length(extension)-1)) '.gif'], 'gif')
        
        fprintf('%s\n', filename);
 	end
end
