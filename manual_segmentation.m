function out = manual_segmentation(fn)


    im_dic = dicominfo(fn);
    im1 = dicomread(im_dic);
    im1(im1 == -2000) = 0; 
    HU = im1 - 1024;
    
    im = im2double(im1);
    min_val = min(im(:));
    max_val = max(im(:));
        
    im_adj = imadjust(im, [min_val; max_val], [0;1] );
    manual_thresh = .57;
    im_adj( im_adj >= manual_thresh) = 0;
    
    bool = im_adj>= .05 & im_adj<=.15;    
    bool_dilated = imdilate(bool, ones(3)); 
    lung = imfill(bool_dilated, 'holes');
    %lung = bool_dilated; 
    
    [L, nlabel] = bwlabel(lung);
    stats = regionprops(L,'Area');
    areas = [stats.Area];
    [sortedX,sortingIndices] = sort(areas,'descend');
    if length(sortedX) >= 2
        max2 = sortedX(2);
    else
        max2 = 10000;
    end        
    idx = find([stats.Area] >= max(max2, 10000) ); % Or max(max2, 20000)??? % This focus on lungs and ignores other regions.
    BW2 = ismember(L,idx);
    out = BW2;  
    
    

end