function AOI_SWEgeotiff(era5file,AMSRsweDir,aoiShp,outFolder,outFile)
%MAKE_AMSRSWE_AOI_GEOTIFF Summary of this function goes here
%   print full record of unifed AMSR SWE data as a geotiff for a
%   AOI/basin. reprojected and stored as geopgraphic data with 1/5 deg
%   cells
%   sweDir - directory full of AMSR_SWE hdf files, name of ERA-5 file, ...
%   aoiShp - shapefile filepath for aoi shapefile
%   X- daily SWE file that is also saved as geotiff
%
%convert aoi to a geogrpahic referenced raster with 1/4 degree cells to match ERA
%5 reanalysis grid
%Timbo Stillinger 2021
%tcs@ucsb.edu

%load AOI shp
S=shaperead(aoiShp,'UseGeoCoords',true);

%load the AOI ERA5 data
v={'SD'};
ptbl='ECMWF128';
gribFlag=true;
ERA5=getERA5(era5file,v,ptbl,gribFlag);
era5sweDates=datetime(ERA5.dateval,'convertFrom','datenum');
eraR = refmatToGeoRasterReference(ERA5.RefMatrix,size(ERA5.X,[1 2]));
era5swe=uint16(ERA5.X.*1000); %M to mm

%reproject vector shapefile as binary mask on the ERA 5 grid.
[Z, ~] = vec2mtx(S.Lat,S.Lon, era5swe(:,:,1), eraR,'filled');
basin=Z<2;

%getAMSR unified SWE dataset and crop/reproject to ERA5 grid
PM=dir(fullfile(AMSRsweDir,'*.hdf'));
numFiles=length(PM);
sweDates=cell(numFiles,1);
k=1;
for i=1:numFiles
    sweFile=fullfile(PM(i).folder,PM(i).name);
    sweDates{i}=PM(i).name(end-11:end-4);
    [SWE,hdr,mask]=getAMSR_USWE(sweFile);
    SWE(mask)=intmax('uint8');%fill (just not SWE)
    
    
    %reproject the SWE to match the basin mask
    try
        basinSWE=rasterReprojection(...
            SWE,hdr.RasterReference,'InProj',hdr.ProjectionStructure,'rasterref',eraR);
    catch
        basinSWE=ones(size(basin),'uint8').*intmax('uint8');
        allFill4aoi{k}=sweFile;%#ok<AGROW>
        k=k+1;
    end
    
    if i==1
        X=basinSWE;
    else
        X=cat(3,X,basinSWE);
    end
end


%write out all data

%write out SWE timeseries reference to geographic coordinates %FIX TO REGOGNIZED EXTRA SAMPLES, THROWS A WARNING RIGHT NOW
%ERA5 SWE and dates
geotiffwrite(fullfile(outFolder,[outFile '_ERA5_SWE.tif']),era5swe,eraR); 
writematrix(era5sweDates,fullfile(outFolder,[outFile 'ERA5_sweDates.csv']))

%AMSR SWE and dates
geotiffwrite(fullfile(outFolder,[outFile '_AMSR_SWE.tif']),X,eraR); 
writecell(sweDates,fullfile(outFolder,[outFile 'AMSR_sweDates.csv']))

%write out basinMask
geotiffwrite(fullfile(outFolder,[outFile '_basinMask.tif']),basin,eraR);
end

