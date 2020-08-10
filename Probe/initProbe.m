function probe = initProbe(handles)

probe = struct( ...
               'name', 'probe', ...
               'pathname', '', ...
               'handles',struct( ...
                                'hSrcpos', [], ...
                                'hDetpos', [], ...
                                'hOptodes', [], ...
                                'hOptodesCircles', [], ...
                                'hMeasList', [], ...
                                'hProjectionPts', [], ...
                                'hProjectionTbl', [-1,-1], ...
                                'hProjectionRays', [], ...
                                'hSprings', [], ...
                                'hSDgui', [], ...
                                'pushbuttonRegisterProbeToSurface', [], ...
                                'checkboxHideProbe', [], ...
                                'checkboxHideSprings', [], ...
                                'checkboxHideDummyOpts', [], ...
                                'checkboxHideMeasList', [], ...
                                'checkboxOptodeSDMode', [], ....
                                'menuItemProbeToCortex',[], ...
                                'menuItemOverlayHbConc',[], ...
                                'menuItemSaveRegisteredProbe', [], ...
                                'menuItemLoadPrecalculatedProfile', [], ...
                                'checkboxOptodeCircles', [], ...
                                'textSpringLenThresh', [], ...
                                'menuItemMakeProbe', [], ...
                                'menuItemImportProbe', [], ...
                                'axes', [] ...
                               ), ...
               'srcpos',[], ...
               'detpos',[], ...
    'dummypos',[], ...
               'srcmap',[], ...
               'detmap',[], ...
               'optpos',[], ...
               'optpos_reg',[], ...
               'optpos_reg_mean',[], ...
               'nsrc',0, ...
               'ndet',0, ...
               'nopt',0, ...
               'noptorig',0, ...
               'mlmp',[], ...
               'mlmp_mean',[], ...
               'ptsProj_cortex',[], ...
               'ptsProj_cortex_mni',[], ...
               'ml',[], ...
               'sl',[], ...
               'al',[], ...
               'hideProbe',0, ...
               'hideMeasList',0, ...
               'hideSprings',0, ...
               'hideDummyOpts',0, ...
               'hOptodesIdx',1, ...
               'posprobe_data',[], ...
               'optViewMode','numbers', ...
               'springLenThresh',[3,10], ...
               'center',[], ...
               'orientation', '', ...
               'checkCompatability',[], ...
               'isempty',@isempty_loc, ...
    'copy',@copy_loc, ...
               'prepObjForSave',[], ...
               'pullToSurfAlgorithm','center', ...
               'rhoSD_ssThresh', 15 ...
              );


if exist('handles','var')
    probe.handles.pushbuttonRegisterProbeToSurface = handles.pushbuttonRegisterProbeToSurface;
    probe.handles.checkboxHideProbe                = handles.checkboxHideProbe;
    probe.handles.checkboxHideSprings              = handles.checkboxHideSprings;
    probe.handles.checkboxHideDummyOpts            = handles.checkboxHideDummyOpts;
    probe.handles.checkboxHideMeasList             = handles.checkboxHideMeasList;
    probe.handles.checkboxOptodeSDMode             = handles.checkboxOptodeSDMode;
    probe.handles.checkboxOptodeCircles            = handles.checkboxOptodeCircles;
    probe.handles.menuItemSaveRegisteredProbe      = handles.menuItemSaveRegisteredProbe;
    probe.handles.menuItemProbeToCortex          = handles.menuItemProbeToCortex;
    probe.handles.menuItemOverlayHbConc            = handles.menuItemOverlayHbConc;
    probe.handles.editSpringLenThresh              = handles.editSpringLenThresh;
    probe.handles.textSpringLenThresh              = handles.textSpringLenThresh;
    probe.handles.menuItemLoadPrecalculatedProfile = handles.menuItemLoadPrecalculatedProfile;
    probe.handles.menuItemMakeProbe                = handles.menuItemMakeProbe;
    probe.handles.menuItemImportProbe              = handles.menuItemImportProbe;
    probe.handles.axes                             = handles.axesSurfDisplay;
    
    set(probe.handles.pushbuttonRegisterProbeToSurface, 'enable','off');
    set(probe.handles.checkboxHideProbe, 'enable','off');
    set(probe.handles.checkboxHideSprings, 'enable','off');
    set(probe.handles.checkboxHideDummyOpts, 'enable','off');
    set(probe.handles.checkboxHideMeasList, 'enable','off');
    set(probe.handles.checkboxOptodeSDMode, 'enable','off');
    set(probe.handles.checkboxOptodeCircles, 'enable','off');
    set(probe.handles.menuItemProbeToCortex, 'enable','off');
    set(probe.handles.menuItemOverlayHbConc, 'enable','off');

    set(probe.handles.menuItemSaveRegisteredProbe,'enable','off');
    set(probe.handles.editSpringLenThresh,'string',num2str(probe.springLenThresh) );
    set(probe.handles.menuItemLoadPrecalculatedProfile, 'enable','off');
    set(probe.handles.menuItemMakeProbe,'enable','on');
    set(probe.handles.menuItemImportProbe,'enable','on');

    probe.hideProbe     = get(probe.handles.checkboxHideProbe,'value');
    probe.hideSprings   = get(probe.handles.checkboxHideSprings,'value');
    probe.hideDummyOpts = get(probe.handles.checkboxHideDummyOpts,'value');
    probe.hideMeasList  = get(probe.handles.checkboxHideMeasList,'value');
    val                 = get(probe.handles.checkboxOptodeCircles,'value');
    if val==1
        probe.optViewMode='circles';
    elseif val==0
        probe.optViewMode='numbers';
    end
end



% --------------------------------------------------------------
function b = isempty_loc(probe)

b = false;
if isempty(probe)
    b = true;
elseif isempty(probe.optpos)
    b = true;
end




% --------------------------------------------------------------
function probe = copy_loc(probe, probe2)

probe.srcpos        = probe2.srcpos;
probe.nsrc          = size(probe2.srcpos,1);
probe.detpos        = probe2.detpos;
probe.ndet          = size(probe2.detpos,1);
probe.optpos        = [probe2.srcpos; probe2.detpos; probe2.dummypos];
probe.noptorig      = size(probe2.optpos,1);
probe.srcmap        = probe2.srcmap;
probe.detmap        = probe2.detmap;
probe.center        = probe2.center;
probe.orientation   = probe2.orientation;
probe.ml            = probe2.ml;
probe.sl            = probe2.sl;
probe.al            = probe2.al;
