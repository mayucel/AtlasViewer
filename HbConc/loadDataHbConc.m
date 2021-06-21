function hbconc = loadDataHbConc(hbconc, dataTree)

if isempty(dataTree)
    return
end

dataTree.currElem.Load();

% Check if there's group acquisition data to load
if ~isempty(dataTree.currElem) && ~dataTree.currElem.IsEmpty()
    hbconc.HbConcRaw = dataTree.currElem.GetDcAvg();
    hbconc.tHRF      = dataTree.currElem.GetTHRF();
    
    %% hacked
    thbo = dataTree.currElem.procStream.output.misc.hmrstats.tval_contrast(:,:,1);
    thbr = dataTree.currElem.procStream.output.misc.hmrstats.tval_contrast(:,:,2);
    a(:,1,:,1)=thbo;
    a(:,1,:,2)=thbo;
    a(:,2,:,1)=thbr;
    a(:,2,:,2)=thbr;
    aa = reshape(a, size(a,1), size(a,2)*size(a,3)*size(a,4));
    aaa = repmat(aa,size(hbconc.tHRF,1),1);
    aaa = reshape(aaa, size(aaa,1), size(a,2),size(a,3),size(a,4));
    hbconc.HbConcRaw = aaa;
    %%
    
end
if length(hbconc.tHRF) >  1
    hbconc.config.tRangeMin = hbconc.tHRF(1);
    hbconc.config.tRangeMax = hbconc.tHRF(end);
end

