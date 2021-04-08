function [ERA5] = getERA5(filename,varid,ptbl,gribFlag)
%GETERA5
%ptbl - parameter table for reading grib data
%gribflag = grib or netCDF dataset of ERA5 data
%Timbo Stillinger/Ned Bair 2021
%tcs@ucsb.edu

%Read file
if gribFlag
    grib_struct=read_grib(filename,varid,'ParamTable',ptbl,'ScreenDiag',0);
    if isempty(grib_struct)
        error('empty grib for file:%s variable: %s',filename,v);
    end
    %Get Matrix Dimensions, create referencing matrix and bounding box
    gds=grib_struct(1).gds;
    Ni=gds.Ni;
    Nj=gds.Nj;
    Di=gds.Di;
    Dj=gds.Dj;
    
    %%%%ERA5 ref info - https://confluence.ecmwf.int/display/CKB/ERA5%3A+What+is+the+spatial+reference
    %no epsg code for grib1 sphere - use 6367.47km sphere for all data
    %ERA5 data center of pixel is lat/lon
    RefMatrix=makerefmat(gds.Lo1,gds.La1, Dj, -Di);
    
    %info that is same for all daily/hourly/monthly records
    units=grib_struct(1).units;
    
    %get data for each record in file (assume all have same spatial info)
    numRecs=length(grib_struct);
    dateval=zeros(numRecs,1);
    for i=1:numRecs
        dt=rot90(reshape(grib_struct(i).fltarray,[Ni Nj]));
        
        if i==1
            X=dt;
        else
            X=cat(3,X,dt);
        end
        
        %Universal Time
        pds=grib_struct(i).pds;
        
        % Add datevals to output structure
        dateval(i)=datenum([pds.year pds.month pds.day ]);%pds.hour pds.min 0]);     
    end
end

ERA5.X=X;
ERA5.dateval=dateval;
ERA5.units=units;
ERA5.RefMatrix=RefMatrix;
ERA5=orderfields(ERA5);
end

