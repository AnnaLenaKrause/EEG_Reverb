% create symmetric HRTF

dp = 'C:\Users\Lars.Hausfeld\Documents\GitHub\EEG_Reverb';
load(fullfile(dp,'RWTH_HRTF.mat'))

hrtfData2 = hrtfData;
nhrtf = size(sourcePosition,1);

for h = 1:nhrtf
    SP = sourcePosition(h,:);    
    if SP(1)>0 && SP(1)<180
        SPnew = SP;
        SPnew(1) = 360-SP(1);
        curh = squeeze(hrtfData(h,:,:));
        revcurh = curh([2 1],:);
        % find correct index to change
        ixelev = find(sourcePosition(:,2)==SP(2));
        ixsymm = find(single(sourcePosition(:,1))==single(SPnew(1)));
        ixnew = intersect(ixelev,ixsymm);
        hrtfData2(ixnew,:,:) = revcurh;
    end
end

hrtfData = hrtfData2;
save(fullfile(dp,'RWTH_HRTF.mat'),'hrtfData','sourcePosition','fs')