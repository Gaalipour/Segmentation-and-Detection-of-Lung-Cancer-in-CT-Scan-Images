function im_instance()
    
    directory = dir('D:/My Project-Spring 2017/stage1/stage1/*');
    
    filename = 'cross_validation.xlsx';
    features = {'ID', '# of CT Images', 'avg_area', 'avg_max', 'avg_HU', 'mu', 'sigma'};
    
    no_patients =200; %length(directory);
    for ii = 710:(no_patients+710)
       
        patient_dic = directory(ii);
        patient_id = sprintf('D:/My Project-Spring 2017/stage1/stage1/%s/*.dcm', patient_dic.name);
        fprintf('Working on Patient with ID %s\n', patient_dic.name)
        addpath(sprintf('D:/My Project-Spring 2017/stage1/stage1/%s/', patient_dic.name));
        images = dir(patient_id);
        
        locations =[];
        no_images_for_this = length(images); 
        fprintf('This patient has %d CT Scan images\n\n', no_images_for_this )

        
        projection = zeros(512, 512);
        refined_HU = zeros(512,512);
        projection_bone = zeros(512, 512); 
        porjection_lung = zeros(512,512);
        porjection_HU = zeros(512,512); 

        for kk = 1:no_images_for_this
            im = images(kk).name;
            im_dic = dicominfo(im);
            locations(kk) = im_dic.InstanceNumber;
        end
        [sortedX,Indc] = sort(locations,'descend');
        mid= floor((no_images_for_this+1)/2 ); 
        middle_image_indices = [mid+51, mid+52, mid+53, mid+54];
        cutt_off = 20; 
        for jj = (1+cutt_off): (no_images_for_this - (cutt_off+25)) %middle_image_indices %1: no_images_for_this%
            im_indx = Indc(jj);
            im = images(im_indx).name;
            im_dic = dicominfo(im);
            im1 = dicomread(im_dic);

            im1(im1 == -2000) = 0; 
            %imagesc(im1);
            %pause(1);
            
            %lung = bone_remover(im1);
            % Tumur finding by high values of HU
            HU = im1 - 1024;
            %bool = (HU>= 1000 & HU <= 3000);
            %im1(bool) = 0; 
            lung1 = manual_segmentation(im) & simple_bone_remover(im) ; % bone_remover(im);
            lung2 = manual_segmentation(im) & new_bone_remover(im); 
            lung = manual_segmentation(im) | simple_bone_remover(im) | new_bone_remover(im); %lung1 | lung2; 
            
            lung = imdilate(lung, ones(5));
            lung = imdilate(lung, ones(9));
            lung = imfill(lung, 'holes'); 
            
            bone = (HU>= 700 & HU <= 3000);
            bone = imdilate(bone, ones(3));
            bone = imfill(bone, 'holes');
            
            refined_HU(HU >= 2000) = 1; 
            projection = projection + double(refined_HU); % projection = projection + (lung & HU >=900)
            projection_bone = projection_bone + bone; 
            porjection_lung = porjection_lung + (lung & (HU >= 700) ); 
            
            temp_HU = double(HU);
            temp_HU(HU<1600) = 0; 
            porjection_HU = porjection_HU + temp_HU; 
            
            %subplot(2,3,1);
            %imagesc(im1);
            %subplot(2,3,2);
            %imagesc(lung);
            %subplot(2,3,3);
            %imagesc( refined_HU ); colormap('gray'); %imagesc(projection/no_images_for_this ); colormap('gray');
            %subplot(2,3,4);
            %imagesc( projection_bone / no_images_for_this ); colormap('gray');
            %subplot(2,3,5);
            %imagesc( porjection_lung / no_images_for_this ); colormap('gray');
            %subplot(2,3,6);
            %imagesc( porjection_HU / no_images_for_this ); colormap('gray');
            
            %pause(1); 

        end    
        
        
        ID = patient_dic.name;
        no_images = no_images_for_this; 
        avg_area = sum(projection(:))/no_images_for_this;
        avg_max = max(projection(:))/no_images_for_this;
        
        avg_HU = max(porjection_HU(:))/no_images_for_this; 
        mu = mean(porjection_lung(:));
        sigma = std(porjection_lung(:)); 
        
        features(ii-1, :) = {ID, no_images,  avg_area, avg_max, avg_HU, mu, sigma}; 
        
        sheet = 6;
        xlRange = 'A1';
        xlswrite(filename,features, sheet,xlRange);

    end
    %features

      
   
end