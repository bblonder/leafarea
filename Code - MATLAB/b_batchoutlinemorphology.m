function [] = b_batchoutlinemorphology(directory, px_per_cm, outputfilename)
    % directory
    % input folder - must end in a trailing slash
    
    % px_per_cm
    % resolution of input images in pixels per centimeter
    
    % outputfilename
    % output file. opened in 'append' mode and written with header in 
    % comma-separated value format

    
    if(directory(length(directory)) ~= '/')
        error('Directory name must end in trailing slash');
    end
    
    % append to file
    outfile = fopen(outputfilename, 'a');

    extension = '.gif';
    files = dir([directory sprintf('*%s', extension)]);

    numFiles = numel(files);

    for k = 1:numFiles
        fprintf('%.3f\n',k/numFiles);
        
        filename = [directory files(k).name];
        image = logical(imread(filename));
        
        % area and perim
        area = bwarea(image);
        perim = bwarea(bwperim(image));
        
        % major and minor axes
        length_maj = regionprops(image, 'MajorAxisLength');
        length_maj = length_maj(1).MajorAxisLength;
        length_min = regionprops(image, 'MinorAxisLength');
        length_min = length_min(1).MinorAxisLength;
        
        % feret diameter ratio
        [xc, yc] = find(image > 0);
        ch = convhull(xc, yc);
        maxdist = max(pdist([xc(ch) yc(ch)]));
        effectivediameter = 2*sqrt(area/pi);
        fdr = maxdist/effectivediameter;
        
        % shape factor
        sf = 4*pi * area / perim^2;

        % major axis (cm), minor axis (cm), feret diameter ratio (dimensionless), shape
        % factor (dimensionless, area (cm2), perimeter (cm)
        if (k==1)
            fprintf(outfile, 'filename,major axis length (cm),minor axis length (cm),elongation ratio (dimensionless),shape factor (dimensionless),feret diameter ratio (dimensionless),area (cm2),perimeter (cm)\n');
        end
        
        fprintf(outfile, '%s,%f,%f,%f,%f,%f,%f,%f\n', files(k).name, length_maj / px_per_cm, length_min / px_per_cm, length_maj / length_min, fdr, sf, area / px_per_cm^2, perim / px_per_cm);
 	end
end
