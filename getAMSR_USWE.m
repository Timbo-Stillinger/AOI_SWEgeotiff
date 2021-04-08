function [SWE,hdr,mask]=getAMSR_USWE(HDFfilename)
% AMSR unifed SWE product from NSIDC
%outputs northern hemisphere SWE only (southern hemi is in files)
%scale factor = 1

%Each data file contains gridded Snow Water Equivalent (SWE) estimates for
%the Northern Hemisphere (SWE_NorthernDaily) and Southern Hemisphere
%(SWE_SouthernDaily). The SWE values have a scale factor of 1 for the
%Northern Hemisphere and a scale factor of 2 for the Southern Hemisphere.
%This data set also includes an ancillary quality assurance text file that
%provides summary statistics for the values included in this field.
%
%Valid parameter values include:
%
%    0-240: SWE values in millimeters (mm)
%    247: Incorrect spacecraft attitude
%    248: Off-earth
%    252: Land/Snow impossible
%    253: Ice
%    254: Water
%    255: Missing or out-of-bounds data
% Each data file also includes a gridded parameter flag field for the Northern Hemisphere (Flags_NorthernDaily) and Southern Hemisphere (Flags_SouthernDaily). The values included in this field are the same as the values in the SWE parameter field with the exception of value 241: Snow Possible. The Snow Possible flag shows all grid cells containing values within the valid SWE data range; 0 and 240 mm.
%
% Valid flag values include:
%
%     241: Snow possible
%     247: Incorrect spacecraft attitude
%     248: Off-earth
%     252: Land/Snow Impossible
%     253: Ice
%     254: Water
%     255: Missing or out-of-bounds data
%
% correctly sets up the mstruct for the amsr projection at nsidc
%https://www.mathworks.com/help/map/projection-aspect.html
%Timbo Stillinger 2021
%tcs@ucsb.edu

I=validateHDF(HDFfilename);
rastersize=[721 721];
%[ hdr ] = GetCoordinateInfo( filename,'/Grid',rastersize );
%projection info
for k=1:length(I.Grid)
    if strfind(I.Grid(k).Name,'Northern Hemisphere')
        dx=(I.Grid(k).LowerRight(1)-I.Grid(k).UpperLeft(1))/(I.Grid(k).Columns);
        dy=(I.Grid(k).LowerRight(2)-I.Grid(k).UpperLeft(2))/(I.Grid(k).Rows);
        x11 = I.Grid(k).UpperLeft(1)+dx/2;
        y11 = I.Grid(k).UpperLeft(2)+dy/2;
        RefMat25km = makerefmat(x11,y11,dx,dy);
        RasRef25km = refmatToMapRasterReference(RefMat25km,...
            [I.Grid(k).Rows I.Grid(k).Columns]);           
    elseif strfind(I.Grid(k).Name,'Southern Hemisphere')
        continue
    else
        warning('file %s does not have the right Grid information',...
            HDFfilename)
        disp(I)
    end 
end
mstruct = defaultm('eqaazim');
mstruct.geoid=I.Grid(1).Projection.ProjParam(1:2);
mstruct = defaultm(mstruct);
mstruct.origin=[90 0 0];
    
hdr.RefMatrix=RefMat25km;
hdr.RasterReference=RasRef25km;
hdr.ProjectionStructure=mstruct;
SWE = hdfread(HDFfilename,'SWE_NorthernDaily');
mask=SWE>240;
end
