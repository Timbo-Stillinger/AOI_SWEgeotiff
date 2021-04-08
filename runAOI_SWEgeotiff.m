outFolder='/path/to/folder/to/save/output/in';
AMSRsweDir='/path/to/folder/with/AMSR_SWE_Unified datasets';

%langtang
era5file='/path/to/folder/with/ERA5/langtang_snow_depth_daily.grib';
aoiShp='/path/to/folder/with/AOI/langtang_catchment_nepal_wgs84.shp';
outFile='langtang_catchment_nepal';
makeAOI_SWEgeotiff(era5file,AMSRsweDir,aoiShp,outFolder,outFile)

%panjsher
era5file='/path/to/folder/with/ERA5/panjsher_snow_depth_daily.grib';
aoiShp='/path/to/folder/with/AOI/panjsher_basin_afghanistan_wgs84.shp';
outFile='panjsher_basin_afghanistan';
makeAOI_SWEgeotiff(era5file,AMSRsweDir,aoiShp,outFolder,outFile)

%wangchu
era5file='/path/to/folder/with/ERA5/wangchu_snow_depth_daily.grib';
aoiShp='/path/to/folder/with/AOI/wangchu_watershed_bhutan_wgs84.shp';
outFile='wangchu_watershed_bhutan';
makeAOI_SWEgeotiff(era5file,AMSRsweDir,aoiShp,outFolder,outFile)