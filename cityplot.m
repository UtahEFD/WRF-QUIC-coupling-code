function fighandle = cityplot(bld,domain,position,name,userdata,tag,varargin)
%fighandle = cityplot(bld,domain,position,name,userdata,tag,varargin)
%this function was mainly created to handle all the figures being plotted
%and since all the figures have the city and the ground in them,
%this function will plot the city and the ground  in the specified position
%with the specified name
%
%position is the position of the figure in vector form.
%i.e. position = [x,y,width,height]
%
%userdata is the group that the figure belongs to i.e 'vectors','contours'...
%
%name/tag should be the unique property that will enable this function to find
%it using the findobj('tag',tag) command
%
%varargin can be one of the following strings paired with a valuefor it:
%   'Bld'     {1=bld},0=nobld  Plot buildings
%   'Gnd'     {1=gnd},0=nognd Plot the ground patch
%   '3D'      {1=3d}, 0=2d  Plots city in 2D/3D dimensions. 2D has x-y plane without ztick marks
%                   and turns off the cameratoolbar orbit fcn, and sets
%                   view to orthographic
%   'Quic2Mat'{0=no quic2mat}, "pdir"= use quic2mat from project directory
%                   Quic2Mat uses quic2mat3 to plot buildings.
%   'Axes'    {1=axes},0=noaxes plot the axes on the figure
%   'Tick'    {1=axes},0=noaxes plot any tick labels
%   'XTick'   {1=axes},0=noaxes plot X tick labels
%   'YTick'   {1=axes},0=noaxes plot Y tick labels
%   'ZTick'   {1=axes},0=noaxes plot Z tick labels
%   'CamMode'    {1=orbit},0=nomode Turns off the default orbit fcn of the cameratoolbar
%   'RePlot'    {0=noreplot},1=replot Replots the city
%   'Blank'     {0=nonblank},1=blank Plots nothing, just opens a blank figure w/ cameratoolbar
%                   orbit fcn off
%   'Azimuth'    Sets the plot to the azmith angle of your choice
%                   Must be followed by an angle
%   'Elevation' Sets the plot to the elevation angle of your choice
%                   Must be followed by an angle
%   'Ortho'     {0=perspective},1=ortho Sets the view to orthographic or perspective
%   'Sensor'    {0=no sensor}, 1=sensors plot the sensors if sensor mode
%
%   This function can also take the above properties as a structure as long
%   as it has ALL the properly defined field names
%   The defaults are listed here:
%
%   param = struct('bld',1,...
%                'gnd',1,...
%                'threed',1,...
%                'quic2mat',0,...
%                'axes',1,...
%                'tick',1,...
%                'xtick',1,...
%                'ytick',1',...
%                'ztick',1,...
%                'cammode',1,...
%                'blank',0,...
%                'az',37.5,...
%                'el',30,...
%                'sameview',1,...
%                'replot',0,...
%                'ortho',0,...
%                'sensor',0,0);
%
%   fighandle is the handle to the current figure just created
%
%   NOTE: this function adds icons to the figure toolbar so the icons need to
%   be in the same directory as the function
%

%-------------------------------------------------------------------------
%initialize all the varargin struct
celltype.x=[];
celltype.y=[];
celltype.z=[];
celltype.c=[];

param = struct('bld',1,...
    'gnd',1,...
    'veg',1,...
    'threed',1,...
    'quic2mat',0,...
    'axes',1,...
    'tick',1,...
    'xtick',1,...
    'ytick',1',...
    'ztick',1,...
    'cammode',1,...
    'blank',0,...
    'az',37.5,...
    'el',30,...
    'sameview',1,...
    'replot',0,...
    'ortho',0,...
    'sensortime',0,...
    'grid',struct('outer_flag',0),...
    'celltype',celltype);
param.sensor.data{1}(1,1)=-1;

% used for animation sensors
point_sensors = [];  % array of the sensor index' that are point sensors
maxsensor_idx = [];  %#ok<NASGU> % the sensor that takes the most iterations to complete full animation

%if there are any extra arguments in
if ~isempty(varargin)

    if isstruct(varargin{1})

        %input the whole structure as one argument
        param = varargin{1};

    else


        %this changes the variables depending on the varargin
        i=1;
        %while i<=length(varargin)
        while i<length(varargin)
            switch lower(varargin{i})%make lower case
                case {'bld','showbld'}%used to be showbld
                    param.bld = varargin{i+1};
                case 'gnd'
                    param.gnd = varargin{i+1};
                case 'veg'
                    param.veg = varargin{i+1};
                case '3d'
                    param.threed = varargin{i+1};
                    %turn off some default params if 2D
                    if param.threed == 0
                        param.cammode = 0;
                        param.ztick = 0;
                        param.ortho = 1;
                    end
                case {'quic2mat','quic2mat'}
                    param.quic2mat = varargin{i+1};
                case 'axes'
                    param.axes = varargin{i+1};
                    %turn off a default
                    if param.axes == 0
                        param.tick = 0;
                    end
                case 'tick'
                    param.tick  = varargin{i+1};
                case 'xtick'
                    param.xtick = varargin{i+1};
                case 'ytick'
                    param.ytick = varargin{i+1};
                case 'ztick'
                    param.ztick = varargin{i+1};
                case 'replot'
                    param.replot = varargin{i+1};
                case 'blank'
                    param.blank = varargin{i+1};
                    %reset some defaults
                    if param.blank == 1
                        param.axes = 0;
                        param.bld = 0;
                        param.gnd = 0;
                        param.tick = 0;
                        param.cammode = 0;
                    end
                case 'azimuth'
                    param.az = varargin{i+1};
                    param.sameview = 0;
                case 'elevation'
                    param.el = varargin{i+1};
                    param.sameview = 0;
                case {'ortho','orthographic'}
                    param.ortho = varargin{i+1};
                case 'cammode'
                    param.cammode = varargin{i+1};
                    param.grid = varargin{i+7};
                case 'sensor'
                    param.sensor = varargin{i+1};
                    param.sensortime = varargin{i+2};
                    param.grid = varargin{i+4};
                case 'celltype'
                    param.celltype = varargin{i+1};
                case 'grid'
                    param.grid = varargin{i+1};
            end
            i=i+2;
        end
    end%isstruct

end %isempty

%this is finding the figure with the unique name
fighandle = findobj('name',name);

%this is deciding if the figure exsists already
if ishandle(fighandle) %it does exist
    figure(fighandle); %makes fighandle the current figure
    % figflag(name,1);%this finds the figure with name and sets the focus
    if param.sameview
        hold on
        [param.az,param.el] = view; %finds current view of figure so it doesn't change
        hold off
    end
%     threed=getappdata(fighandle,'threed');
%     if param.threed ~= threed;
%         param.replot = 1;
% %         if param.threed;
% %             set(fighandle,'renderer','opengl','renderermode','manual');
% %         else
% %             set(fighandle,'renderer','painters','renderermode','manual');
% %         end
%     end;
else%it doesn't exsist so the figure is created

    if param.cammode
        mode = 'default';
    else
        mode = 'nomode';%turns off cameratoolbar orbit fcn
    end

    fighandle = figure('Position', position,'Name',name,'numbertitle','off',...
        'createfcn',{@ctb,mode},'userdata',userdata,'tag',tag,'visible','off','color','w');
    %
    % used for animation of the sensors so that motion function
    % doesn't surpass the recursion limit
    setappdata(fighandle,'CurrentAnimationStatus',0);

    if param.sameview
        param.al = 37.5;%azmith angle
        param.el = 30;%elevation angle
    end
    %     create_quicgui_viewmenus(fighandle)
    
%     if param.threed;
%         set(fighandle,'renderer','opengl','renderermode','manual');
%     else
%         set(fighandle,'renderer','painters','renderermode','manual');
%     end
    
    hidden = get(0,'showhiddenhandles');
    set(0,'showhiddenhandles','on');

    %this is getting the handle to the current figures toolbar
    fig_tool = findobj(fighandle,'tag','FigureToolBar');
    %     cameratoolbar(fighandle);
    cam_tool = findobj(fighandle,'tag','CameraToolBar');

    %reading the image data for the push buttons
    xview = imread(fullfile('images','yzplane.bmp'));
    yview = imread(fullfile('images','xzplane.bmp'));
    zview = imread(fullfile('images','xyplane.bmp'));
    dview = imread(fullfile('images','dplane.bmp'));
    axistoggledwn = imread(fullfile('images','axistoggledwn.bmp'));
    axistoggleup = imread(fullfile('images','axistoggleup.bmp'));

    %this is when the cdata doesn't change for the toggle button
    axistoggle_data = axistoggleup;

    setappdata(fighandle,'AxisToggleUp',axistoggleup);
    setappdata(fighandle,'AxisToggleDwn',axistoggledwn);


    %there are two types of buttons that i have figured out so far:
    %uipushtool
    %uitoggletool

    %creating a pushbutton inside the figure toolbar
    uipushtool('parent',fig_tool,'Click','AlignView(''x'')',...
        'cdata',xview,'Tag','xview');
    uipushtool('parent',fig_tool,'Click','AlignView(''y'')',...
        'cdata',yview,'Tag','yview');
    uipushtool('parent',fig_tool,'Click','AlignView(''z'')',...
        'cdata',zview,'Tag','zview');
    uipushtool('parent',fig_tool,'Click','AlignView(''d'')',...
        'cdata',dview,'Tag','dview');
    %this toggle button will be defaulted to the down position for now
    htggle = uitoggletool('parent',fig_tool,'Click',...
        {@axistoggle,fighandle},'cdata',axistoggle_data,...
        'Tag','axistoggle','state','on'); %#ok<NASGU>

    %this puts the camera toolbar below the figure toolbar
    %this is makes the figure flash a couple times once it's open so a
    %better solution should be found
    h = uipushtool('parent',cam_tool,'Click','','tag','nothing');
    delete(h);

    %this makes it visible after all the previous toolbar switches take
    %place
    set(fighandle,'visible','on');
    set(0,'showhiddenhandles',hidden);

    param.replot = 1;%flag to plot buildings

    setappdata(fighandle,'threed',param.threed);
end %figure creation
setappdata(fighandle,'showbld',param.bld);
setappdata(fighandle,'showveg',param.veg);
hold on

%this is the parameters used to plot each city
[bldnfo,gndnfo] = cityplot_params;
zmin = 0;

if param.replot
    cla
end
if param.quic2mat == 0  %if quic2mat3 is used don't plot ground

    groundpatch = findobj(fighandle,'tag','GroundPatch');
    
    
    %plotting the ground or the map
    if param.gnd

        if ishandle(groundpatch) & param.replot == 0
            if strcmp(get(groundpatch,'visible'),'off')
                set(groundpatch,'visible','on');
            end
        else


            %plotting the background picture for the ground if there is a picture
            %and it is turned on
            if ~isempty(domain.bckgnd.pic) && strcmp(gndnfo.map,'on')
                %this resizes the image to the right size
                %the methods of resizing  are bicubic, bilinear and nearest
                %which are in order of greatest resolution to least resolution and
                %slowest to quickest
                %times for a 158 x 200 pixel picture
                %bicubic = .24
                %bilinear = .21       the resolution is about the same as bicubic
                %(kinda fuzzy though)
                %nearest = .01        more crisp, but missing some pixels
                
%                 area((1:(domain.y+1)*domain.dy),(1:(domain.x+1)*domain.dx)) = domain.dz/100;
%                 pic=surface(area,domain.bckgnd.pic,'facecolor','texturemap','facealpha',1,...
%                     'edgecolor','none','cdatamapping','direct');
%                     
                [npicy,npicx,npicc]=size(domain.bckgnd.pic);
%                 picx=ones(npicy,1)*((0:npicx-1)*domain.x*domain.dx/(npicx-1));
%                 picy=((0:npicy-1)'*domain.y*domain.dy/(npicy-1))*ones(1,npicx);
%                 if param.threed;
                    area=(domain.dz/100)*ones(npicy,npicx);
                    pic=surf(domain.bckgnd.x,domain.bckgnd.y,area,domain.bckgnd.pic,'facecolor','texturemap','facealpha',1,...
                        'edgecolor','none','cdatamapping','direct','hittest','off');
%                 else
%                     pic=tcolor(domain.bckgnd.x,domain.bckgnd.y,domain.bckgnd.pic);
%                 end;
                grid on
                set(gca,'ydir','normal');

                set(pic,'tag','GroundPatch');

            else %plotting a plane flat ground
                xmin = 0;
                ymin = 0;
                zmin = -domain.dz/100;
                zmax = 0;
                xmax = domain.x*domain.dx;
                ymax = domain.y*domain.dy;

                %defining every vertex and face to be plotted for the ground
%                 if param.threed;
                    v = [xmin ymin zmin;xmax ymin zmin;xmax ymin zmax;...
                        xmin ymin zmax;xmin ymax zmax;xmax ymax zmax;...
                        xmax ymax zmin;xmin ymax zmin];
                    
                    f = [1 2 3 4;2 7 6 3;7 8 5 6;8 1 4 5;4 3 6 5;1 2 7 8];
                    ground = patch('Vertices',v,'Faces',f);
                    
                    if isequal(gndnfo.transparent,'on')
                        set(ground,'facealpha',.5);
                    end
%                 else
%                     ground = patch([xmin,xmax,xmax,xmin],[ymin,ymin,ymax,ymax],[1,1,1]);
%                 end;
                set(ground,'tag','GroundPatch');
                %this checks to see if the user wants the ground transparent
                set(ground,'FaceColor',gndnfo.color,'EdgeColor','none','hittest','off');
            end
        end
    else%turn off the ground if it has already been plotted

        if ishandle(groundpatch)
            set(groundpatch,'visible','off');
        end

    end %if nognd
    
    topolines = findobj(fighandle,'tag','TopoLines');
    if strcmp(gndnfo.topo,'on') & domain.elevation.mode;
        if ishandle(topolines) & param.replot == 0
            if strcmp(get(topolines,'visible'),'off')
                set(topolines,'visible','on');
            end
        else
            elev=domain.elevation.data(2:end-1,2:end-1);
            minelev=min(min(elev));
            maxelev=max(max(elev));
            if maxelev~=minelev;
%                 if param.threed;
                    [topox,topoy,topoz]=meshgrid((0.5:domain.x)*domain.dx,...
                        (0.5:domain.y)*domain.dy,[domain.dz/100,domain.dz/50]);
                    elev_data=0*topoz;
                    elev_data(:,:,1)=elev;
                    elev_data(:,:,2)=elev;
                    topovect = compute_topolevels(elev);
                    topolines = qp_contourslice(topox,topoy,topoz,...
                        elev_data,[],[],domain.dz/50,topovect);
                    if strcmp(gndnfo.topolabels,'on');
                        [C,h] = contour3(topox(:,:,1),topoy(:,:,1),elev,topovect);
                        delete(h);
                        clabel(C,topolines,'LabelSpacing',300);
                    end;
                    set(topolines,'tag','TopoLines','edgecolor','k','hittest','off');
%                 else
%                     [topox,topoy]=meshgrid((0.5:domain.x)*domain.dx,(0.5:domain.y)*domain.dy);
%                     [C,topolines] = contour(topox,topoy,elev);
%                     if strcmp(gndnfo.topolabels,'on');
%                         set(topolines,'ShowText','on','TextStep',get(topolines,'LevelStep')*2)
%                     end;
%                     set(topolines,'tag','TopoLines','edgecolor','k');
%                 end;
            end;
        end
    else
        if ishandle(topolines)
            set(topolines,'visible','off');
        end
    end;

end %if quic2mat
buildpatch = findobj(fighandle,'tag','BuildPatch');
garagepatch = findobj(fighandle,'tag','GaragePatch');
vegpatch = findobj(fighandle,'tag','VegPatch');

%this turns building numbering on or off
bldnums = findobj(fighandle,'tag','BuildNums');
plotbldnums=0;
if ~isempty(bldnums);
    if strcmp(bldnfo.numbered,'on')
        set(bldnums,'visible','on');
    else
        set(bldnums,'visible','off');
    end
elseif strcmp(bldnfo.numbered,'on')
    plotbldnums=1;
end;
% JENNY - 9/7/05

% if ~isempty(bld);
%     if ~isempty(bld(1).pos);
%         veg_flag=0;
%         for i = 1:size(bld,1);
%             if bld(i).pos(2)==9;
%                 veg_flag=1;
%             end;
%         end;
%         if veg_flag;
%             
%         end;
%     end;
% end;
% JENNY - 9/7/05
% buildframe = findobj(fighandle,'tag','BuildFrame');
%if the building has been patched and it doesn't need to be plotted again
%just edit the visibility of the buildings
replotfaces=0;
if ~isempty(buildpatch) | ~isempty(garagepatch);
    if ~max([ishandle(buildpatch),ishandle(garagepatch)]) & param.bld;
        replotfaces=1;
    end;
else
    if param.bld;
        replotfaces=1;
    end;
end;
if ~isempty(vegpatch);
    if ~max(ishandle(vegpatch)) & param.veg;
        replotfaces=1;
    end;
else
    if param.veg;
        replotfaces=1;
    end;
end;
if replotfaces == 0 & param.replot == 0;
    if ishandle(buildpatch);
        if param.bld;
            if strcmp(get(buildpatch(1),'visible'),'off')
                set(buildpatch,'visible','on');
            end
        else
            if strcmp(get(buildpatch(1),'visible'),'on')
                set(buildpatch,'visible','off');
            end
        end;
    end;
    if ishandle(garagepatch);
        if param.bld;
            if strcmp(get(garagepatch(1),'visible'),'off')
                set(garagepatch,'visible','on');
            end
        else
            if strcmp(get(garagepatch(1),'visible'),'on')
                set(garagepatch,'visible','off');
            end
        end;
    end;
    if ishandle(vegpatch);
        vegframe = findobj(fighandle,'tag','VegFrame');
        if param.veg;
            if strcmp(get(vegpatch(1),'visible'),'off')
                set(vegpatch,'visible','on');
                set(vegframe,'visible','on');
            end
        else
            set(vegpatch,'visible','off');
            set(vegframe,'visible','off');
        end
    end;
else

    %quic2mat decides whether to use the input.dat file or the quic2mat3.m
    %function for plotting the buildings
    if param.quic2mat == 0

        %the buildings dimensions are calculated even if the buildings are
        %not turned on so that the buildings frames can still be plotted

        if domain.building_flag;
%             if param.threed;
                fv=isosurface(domain.building_array.x,domain.building_array.y,...
                    domain.building_array.z,domain.building_array.data,.001);
                p=patch(fv);
                set(p,'FaceColor',0.7*[1,1,1],'EdgeColor','none'); %modify patches
                %[p,d] = quic2mat3(param.quic2mat);
                set(p,'tag','BuildPatch','hittest','off');
                if ~param.bld
                    set(p,'visible','off')
                end
%             else
%                 buildingcells=ones(domain.y,domain.x)*NaN;
%                 for i=1:domain.x;
%                     for j=1:domain.y;
%                         if domain.building_array.data(j,i,2)==0;
%                             buildingcells(j,i)=1;
%                         end;
%                     end;
%                 end;
%                 p=pcolor(domain.building_array.x(:,:,1),domain.building_array.y(:,:,1),buildingcells,...
%                     'edgecolor','none','facecolor',0.7*[1,1,1]);
%                 set(p,'tag','BuildPatch');
%                 if ~param.bld
%                     set(p,'visible','off')
%                 end
%             end;
        elseif ~isempty(bld)  %check for empty matrix
            if ~isempty(bld(1).geometry)
                %finding the max height for a better colormap resolution
                % JENNY - 10/14/05 -->
                tot_height=zeros(1,length(bld));
                for i=1:length(bld)
                    if bld(i).type~=2 & bld(i).damage<2;
                        tot_height(i) = bld(i).height + bld(i).zfo;
                    end
                end
                if ~isempty(find(tot_height>0,1));
                    max_height = max(tot_height(logical(tot_height)));
                    min_height = min(tot_height(logical(tot_height)))-1;
                    diff_height = max_height - min_height;
                end;
                % JENNY - 10/14/05 <--
                %this runs through a for loop and plots one building each loop
                plot_bld=1;
                if plot_bld;
                    for i=1:length(bld);
                        if bld(i).damage==2;
                            continue
                        end;
                        geometry = bld(i).geometry;
                        type = bld(i).type;
                        height = bld(i).height;
                        width = bld(i).width;
                        strct_length = bld(i).length;
                        xfo = bld(i).xfo;
                        yfo = bld(i).yfo;
                        zfo = bld(i).zfo;
                        gamma = bld(i).rotation*pi/180;
                        roofflag = bld(i).roofflag;
                        wallthickness = bld(i).wallthickness;
                        x=[];y=[];z=[];%this clears x y and z each time
                        v=[];f=[];
                        pc=[];
                        if param.grid.outer_flag == 1;
                            xfo = xfo + param.grid.in_grid_loc.x;
                            yfo = yfo + param.grid.in_grid_loc.y;
                        end;
                        switch geometry
                            case 1 %rectangular buildings
                                %defining the vertices
                                x1=xfo+0.5*width*sin(gamma);
                                y1=yfo-0.5*width*cos(gamma);
                                x4=xfo-0.5*width*sin(gamma);
                                y4=yfo+0.5*width*cos(gamma);
                                x2=x1+strct_length*cos(gamma);
                                y2=y1+strct_length*sin(gamma);
                                x3=x4+strct_length*cos(gamma);
                                y3=y4+strct_length*sin(gamma);
%                                 if param.threed;
                                    v = [x1, y1, zfo; x2, y2, zfo;...
                                        x2, y2, zfo+height; x1, y1, zfo+height;...
                                        x4, y4, zfo+height; x3, y3, zfo+height;...
                                        x3, y3, zfo; x4, y4, zfo];
                                    %defining the faces
                                    f = [1 2 3 4;2 7 6 3;7 8 5 6;8 1 4 5;4 3 6 5;1 2 7 8];
                                    %defining the frames for the buildings
                                    %xcoords for north,south,east and west faces for
                                    x_n = [x4,x3,x3,x4,x4];
                                    x_s = [x1,x2,x2,x1,x1];
                                    x_e = [x3,x2,x2,x3,x3];
                                    x_w = [x4,x1,x1,x4,x4];
                                    %ycoords
                                    y_n = [y4,y3,y3,y4,y4];
                                    y_s = [y1,y2,y2,y1,y1];
                                    y_e = [y3,y2,y2,y3,y3];
                                    y_w = [y4,y1,y1,y4,y4];
                                    %zcoords
                                    z = [zfo,zfo,zfo+height,zfo+height,zfo];
                                    %this will plot the frame of the buildings
                                    pc(1) = plot3(x_s,y_s,z);
                                    pc(2) = plot3(x_e,y_e,z);
                                    pc(3) = plot3(x_n,y_n,z);
                                    pc(4) = plot3(x_w,y_w,z);
%                                 else
%                                     v = [x1, y1;...
%                                         x2,y2;...
%                                         x3,y3;...
%                                         x4,y4;
%                                         x1,y1];
%                                     f=[1,2,3,4];
%                                     pc=plot(v(:,1),v(:,2));
%                                 end;
                                if type == 2;
                                    set(pc,'tag','VegFrame');
                                else
                                    set(pc,'tag','BuildFrame');
                                end;
                                xnum_loc = xfo+0.5*strct_length*cos(gamma);
                                ynum_loc = yfo+0.5*strct_length*sin(gamma);
                            case 2 %circular/ellipse cylindrical
                                % these are the equations to make an oval/circle
                                xc = xfo+0.5*strct_length*cos(gamma); %location of blding num
                                yc = yfo+0.5*strct_length*sin(gamma);
                                xr = strct_length*0.5;%major/minor radius
                                yr = width*0.5;%major/minor radius
                                %this will produce 3 matrices that are 25 X 2 both rows of x1 and y1
                                %will have the exact same values.  x1 and y1 will produce a circle. z1 is
                                %just zeros and ones I am throwing out the z1 values anyways, because they
                                %are useless to me.  this will be a unit circle.
                                n=24;%this is and even number vetices around the circle
                                [xcyl,ycyl,z] = cylinder(1,n);
                                %if I multipy the values by their actual radii and add the ellipse center
                                %value then it will produce an ellipse.
                                x = xcyl(1,:)*xr*cos(gamma)-ycyl(1,:)*yr*sin(gamma)+xc;
                                y = xcyl(1,:)*xr*sin(gamma)+ycyl(1,:)*yr*cos(gamma)+yc;
%                                 if param.threed;
                                    z = z*(zfo+height);
                                    v=zeros(2*n,3);
                                    for j=1:n
                                        %the bottom vertices
                                        v(j,1) = x(1,j);
                                        v(j,2) = y(1,j);
                                        v(j,3) = zfo;
                                        %the top vertices
                                        v(j+n,1) = x(1,j);
                                        v(j+n,2) = y(1,j);
                                        v(j+n,3) = zfo+height;
                                    end
                                    % Defining the vertical faces
                                    f=zeros(n+n/2-1,4);
                                    for j=1:n-1
                                        f(j,1) = j;
                                        f(j,2) = j+1;
                                        f(j,3) = j+n+1;
                                        f(j,4) = j+n;
                                    end
                                    f(n,1) = n;
                                    f(n,2) = 1;
                                    f(n,3) = n+1;
                                    f(n,4) = 2*n;
                                    %the top of the cylinder
                                    for j=n+1:n+n/2-1
                                        f(j,1) = j;
                                        f(j,2) = j+1;
                                        f(j,3) = 3*n-j;
                                        f(j,4) = 3*n-j+1;
                                    end
                                    %this will only plot the circle/ellipse edge on top so the user can
                                    %see the edge better
                                    pc(1) = plot3(x(1,:),y(1,:),z(1,:));
                                    pc(2) = plot3(x(1,:),y(1,:),z(2,:));
%                                 else
%                                     v=zeros(n,2);
%                                     for j=1:n
%                                         v(j,1) = x(1,j);
%                                         v(j,2) = y(1,j);
%                                     end;
%                                     f=1:n;
%                                     pc=plot(x(1,:),y(1,:));
%                                 end;
                                if type == 2;
                                    set(pc,'tag','VegFrame');
                                else
                                    set(pc,'tag','BuildFrame');
                                end;
                                xnum_loc = xfo+0.5*strct_length*cos(gamma);
                                ynum_loc = yfo+0.5*strct_length*sin(gamma);
                                
                            case 3  % pentagon
                                r  = width*0.5;
                                r_inner  = r*0.4;
                                t1=(pi/10+gamma);
                                t2=(-3*pi/10+gamma);
                                t3=(-7*pi/10+gamma);
                                t4=(9*pi/10+gamma);
                                t5=(pi*0.5+gamma);
%                                 if param.threed;
                                    v = [xfo + r*cos(t5), yfo + r*sin(t5), zfo;...
                                        xfo + r*cos(t1), yfo + r*sin(t1), zfo;...
                                        xfo + r*cos(t2), yfo + r*sin(t2), zfo;...
                                        xfo + r*cos(t3), yfo + r*sin(t3), zfo;...
                                        xfo + r*cos(t4), yfo + r*sin(t4), zfo;...
                                        xfo + r*cos(t5), yfo + r*sin(t5), zfo + height;...
                                        xfo + r*cos(t1), yfo + r*sin(t1), zfo + height;...
                                        xfo + r*cos(t2), yfo + r*sin(t2), zfo + height;...
                                        xfo + r*cos(t3), yfo + r*sin(t3), zfo + height;...
                                        xfo + r*cos(t4), yfo + r*sin(t4), zfo + height;...
                                        xfo + r_inner*cos(t5), yfo + r_inner*sin(t5), zfo;...
                                        xfo + r_inner*cos(t1), yfo + r_inner*sin(t1), zfo;...
                                        xfo + r_inner*cos(t2), yfo + r_inner*sin(t2), zfo;...
                                        xfo + r_inner*cos(t3), yfo + r_inner*sin(t3), zfo;...
                                        xfo + r_inner*cos(t4), yfo + r_inner*sin(t4), zfo;...
                                        xfo + r_inner*cos(t5), yfo + r_inner*sin(t5), zfo + height;...
                                        xfo + r_inner*cos(t1), yfo + r_inner*sin(t1), zfo + height;...
                                        xfo + r_inner*cos(t2), yfo + r_inner*sin(t2), zfo + height;...
                                        xfo + r_inner*cos(t3), yfo + r_inner*sin(t3), zfo + height;...
                                        xfo + r_inner*cos(t4), yfo + r_inner*sin(t4), zfo + height];
                                    f = [1 2 7 6 1 2;...
                                        2 3 8 7 2 3;...
                                        3 4 9 8 3 4;...
                                        4 5 10 9 4 5;...
                                        5 1 6 10 5 1;...
                                        11 12 17 16 11 12;...
                                        12 13 18 17 12 13;...
                                        13 14 19 18 13 14;...
                                        14 15 20 19 14 15;...
                                        15 11 16 20 15 11;...
                                        6  7  17 16 6  7;...
                                        7  8  18 17 7  8;...
                                        8  9  19 18 8  9;...
                                        9  10 20 19 9  10;...
                                        10 6  16 20 10 6];
                                    face_point(:,:,1)  = [v(1,:); v(2,:); v(7,:); v(6,:)] ; % upper right face corners
                                    face_point(:,:,2)  = [v(2,:); v(3,:); v(8,:); v(7,:)];
                                    face_point(:,:,3)  = [v(8,:); v(9,:); v(4,:); v(3,:)];
                                    face_point(:,:,4)  = [v(4,:); v(5,:); v(10,:); v(9,:)];
                                    face_point(:,:,5)  = [v(5,:); v(1,:); v(6,:); v(10,:)];  % upper left face corners
                                    face_point(:,:,6)  = [v(11,:); v(12,:); v(17,:); v(16,:)] ; % upper right face corners
                                    face_point(:,:,7)  = [v(12,:); v(13,:); v(18,:); v(17,:)];
                                    face_point(:,:,8)  = [v(18,:); v(19,:); v(14,:); v(13,:)];
                                    face_point(:,:,9)  = [v(14,:); v(15,:); v(20,:); v(19,:)];
                                    face_point(:,:,10) = [v(15,:); v(11,:); v(16,:); v(20,:)];  % upper left face corners
                                    pc(1)  = plot3(face_point(:,1,1),face_point(:,2,1),face_point(:,3,1));
                                    pc(2)  = plot3(face_point(:,1,2),face_point(:,2,2),face_point(:,3,2));
                                    pc(3)  = plot3(face_point(:,1,3),face_point(:,2,3),face_point(:,3,3));
                                    pc(4)  = plot3(face_point(:,1,4),face_point(:,2,4),face_point(:,3,4));
                                    pc(5)  = plot3(face_point(:,1,5),face_point(:,2,5),face_point(:,3,5));
                                    pc(6)  = plot3(face_point(:,1,6),face_point(:,2,6),face_point(:,3,6));
                                    pc(7)  = plot3(face_point(:,1,7),face_point(:,2,7),face_point(:,3,7));
                                    pc(8)  = plot3(face_point(:,1,8),face_point(:,2,8),face_point(:,3,8));
                                    pc(9)  = plot3(face_point(:,1,9),face_point(:,2,9),face_point(:,3,9));
                                    pc(10) = plot3(face_point(:,1,10),face_point(:,2,10),face_point(:,3,10));
%                                 else
%                                     v = [xfo + r*cos(t5), yfo + r*sin(t5);...
%                                         xfo + r*cos(t1), yfo + r*sin(t1);...
%                                         xfo + r*cos(t2), yfo + r*sin(t2);...
%                                         xfo + r*cos(t3), yfo + r*sin(t3);...
%                                         xfo + r*cos(t4), yfo + r*sin(t4);...
%                                         xfo + r*cos(t5), yfo + r*sin(t5);...
%                                         NaN, NaN;...
%                                         xfo + r_inner*cos(t5), yfo + r_inner*sin(t5);...
%                                         xfo + r_inner*cos(t1), yfo + r_inner*sin(t1);...
%                                         xfo + r_inner*cos(t2), yfo + r_inner*sin(t2);...
%                                         xfo + r_inner*cos(t3), yfo + r_inner*sin(t3);...
%                                         xfo + r_inner*cos(t4), yfo + r_inner*sin(t4):...
%                                         xfo + r_inner*cos(t5), yfo + r_inner*sin(t5)];
%                                     f = [1,2,3,4,5,6,13,12,11,10,9,8,6];
%                                     pc = plot(v(:,1),v(:,2));
%                                 end;
                                set(pc,'tag','BuildFrame');
                                xnum_loc = xfo;
                                ynum_loc = yfo;
                            case 4;
                                if roofflag;
                                    roof_frac=0.8;
                                else
                                    roof_frac=1;
                                end;
                                x1=xfo+0.5*width*sin(gamma);
                                y1=yfo-0.5*width*cos(gamma);
                                x4=xfo-0.5*width*sin(gamma);
                                y4=yfo+0.5*width*cos(gamma);
                                x2=x1+strct_length*cos(gamma);
                                y2=y1+strct_length*sin(gamma);
                                x3=x4+strct_length*cos(gamma);
                                y3=y4+strct_length*sin(gamma);
                                xfoin=xfo+wallthickness*cos(gamma);
                                yfoin=yfo+wallthickness*sin(gamma);
                                x1in=xfoin+(0.5*width-wallthickness)*sin(gamma);
                                y1in=yfoin-(0.5*width-wallthickness)*cos(gamma);
                                x4in=xfoin-(0.5*width-wallthickness)*sin(gamma);
                                y4in=yfoin+(0.5*width-wallthickness)*cos(gamma);
                                x2in=x1in+(strct_length-2*wallthickness)*cos(gamma);
                                y2in=y1in+(strct_length-2*wallthickness)*sin(gamma);
                                x3in=x4in+(strct_length-2*wallthickness)*cos(gamma);
                                y3in=y4in+(strct_length-2*wallthickness)*sin(gamma);
%                                 if param.threed;
                                    if ~roofflag;
                                        v = [x1, y1, zfo;... %1
                                            x2, y2, zfo;... %2
                                            x2, y2, zfo+height;... %3
                                            x1, y1, zfo+height;... %4
                                            x4, y4, zfo+height;... %5
                                            x3, y3, zfo+height;... %6
                                            x3, y3, zfo;... %7
                                            x4, y4, zfo;... %8
                                            x1in, y1in, zfo;... %9
                                            x2in, y2in, zfo;... %10
                                            x3in, y3in, zfo;... %11
                                            x4in, y4in, zfo]; %12
                                        
                                        %defining the faces
                                        f = [1 2 3 4;...
                                            2 7 6 3;...
                                            7 8 5 6;...
                                            8 1 4 5;...
                                            1 2 10 9;...
                                            2 7 11 10;...
                                            7 8 12 11;...
                                            1 8 12 9;...
                                            4 3 10 9;...
                                            3 6 11 10;...
                                            6 5 12 11;...
                                            4 5 12 9];
                                        
                                        %defining the frames for the buildings
                                        
                                        %xcoords for north,south,east and west faces for
                                        x_n = [x4,x3,x3,x4,x4];
                                        x_s = [x1,x2,x2,x1,x1];
                                        x_e = [x3,x2,x2,x3,x3];
                                        x_w = [x4,x1,x1,x4,x4];
                                        x_c = [x1in,x2in,x3in,x4in,x1in];
                                        %ycoords
                                        y_n = [y4,y3,y3,y4,y4];
                                        y_s = [y1,y2,y2,y1,y1];
                                        y_e = [y3,y2,y2,y3,y3];
                                        y_w = [y4,y1,y1,y4,y4];
                                        y_c = [y1in,y2in,y3in,y4in,y1in];
                                        
                                        %zcoords
                                        z = [zfo,zfo,zfo+height,zfo+height,zfo];
                                        z_c = [zfo,zfo,zfo,zfo,zfo];
                                        %this will plot the frame of the buildings
                                        pc(1) = plot3(x_s,y_s,z);
                                        pc(2) = plot3(x_e,y_e,z);
                                        pc(3) = plot3(x_n,y_n,z);
                                        pc(4) = plot3(x_w,y_w,z);
                                        pc(5) = plot3(x_c,y_c,z_c);
                                        pc(6) = plot3([x1,x1in],[y1,y1in],[zfo+height,zfo]);
                                        pc(7) = plot3([x2,x2in],[y2,y2in],[zfo+height,zfo]);
                                        pc(8) = plot3([x3,x3in],[y3,y3in],[zfo+height,zfo]);
                                        pc(9) = plot3([x4,x4in],[y4,y4in],[zfo+height,zfo]);
                                    else
                                        xforoof(1)=xfo+(wallthickness*(1/3)^2)*cos(gamma);
                                        yforoof(1)=yfo+(wallthickness*(1/3)^2)*sin(gamma);
                                        x1roof(1)=xforoof(1)+(0.5*width-(wallthickness*(1/3)^2))*sin(gamma);
                                        y1roof(1)=yforoof(1)-(0.5*width-(wallthickness*(1/3)^2))*cos(gamma);
                                        x4roof(1)=xforoof(1)-(0.5*width-(wallthickness*(1/3)^2))*sin(gamma);
                                        y4roof(1)=yforoof(1)+(0.5*width-(wallthickness*(1/3)^2))*cos(gamma);
                                        x2roof(1)=x1roof(1)+(strct_length-2*(wallthickness*(1/3)^2))*cos(gamma);
                                        y2roof(1)=y1roof(1)+(strct_length-2*(wallthickness*(1/3)^2))*sin(gamma);
                                        x3roof(1)=x4roof(1)+(strct_length-2*(wallthickness*(1/3)^2))*cos(gamma);
                                        y3roof(1)=y4roof(1)+(strct_length-2*(wallthickness*(1/3)^2))*sin(gamma);
                                        xforoof(2)=xfo+(wallthickness*(2/3)^2)*cos(gamma);
                                        yforoof(2)=yfo+(wallthickness*(2/3)^2)*sin(gamma);
                                        x1roof(2)=xforoof(2)+(0.5*width-(wallthickness*(2/3)^2))*sin(gamma);
                                        y1roof(2)=yforoof(2)-(0.5*width-(wallthickness*(2/3)^2))*cos(gamma);
                                        x4roof(2)=xforoof(2)-(0.5*width-(wallthickness*(2/3)^2))*sin(gamma);
                                        y4roof(2)=yforoof(2)+(0.5*width-(wallthickness*(2/3)^2))*cos(gamma);
                                        x2roof(2)=x1roof(2)+(strct_length-2*(wallthickness*(2/3)^2))*cos(gamma);
                                        y2roof(2)=y1roof(2)+(strct_length-2*(wallthickness*(2/3)^2))*sin(gamma);
                                        x3roof(2)=x4roof(2)+(strct_length-2*(wallthickness*(2/3)^2))*cos(gamma);
                                        y3roof(2)=y4roof(2)+(strct_length-2*(wallthickness*(2/3)^2))*sin(gamma);
                                        v = [x1, y1, zfo;... %1
                                            x2, y2, zfo;... %2
                                            x2, y2, zfo+roof_frac*height;... %3
                                            x1, y1, zfo+roof_frac*height;... %4
                                            x4, y4, zfo+roof_frac*height;... %5
                                            x3, y3, zfo+roof_frac*height;... %6
                                            x3, y3, zfo;... %7
                                            x4, y4, zfo;... %8
                                            x1in, y1in, zfo;... %9
                                            x2in, y2in, zfo;... %10
                                            x3in, y3in, zfo;... %11
                                            x4in, y4in, zfo;... %12
                                            x1roof(1), y1roof(1), zfo+(roof_frac+(1/3)*(1-roof_frac))*height;... %13
                                            x2roof(1), y2roof(1), zfo+(roof_frac+(1/3)*(1-roof_frac))*height;... %14
                                            x3roof(1), y3roof(1), zfo+(roof_frac+(1/3)*(1-roof_frac))*height;... %15
                                            x4roof(1), y4roof(1), zfo+(roof_frac+(1/3)*(1-roof_frac))*height;... %16
                                            x1roof(2), y1roof(2), zfo+(roof_frac+(2/3)*(1-roof_frac))*height;... %17
                                            x2roof(2), y2roof(2), zfo+(roof_frac+(2/3)*(1-roof_frac))*height;... %18
                                            x3roof(2), y3roof(2), zfo+(roof_frac+(2/3)*(1-roof_frac))*height;... %19
                                            x4roof(2), y4roof(2), zfo+(roof_frac+(2/3)*(1-roof_frac))*height;... %20
                                            x1in, y1in, zfo+height;... %21
                                            x2in, y2in, zfo+height;... %22
                                            x3in, y3in, zfo+height;... %23
                                            x4in, y4in, zfo+height]; %24
                                        
                                        %defining the faces
                                        f = [1 2 3 4;...
                                            2 7 6 3;...
                                            7 8 5 6;...
                                            8 1 4 5;...
                                            1 2 10 9;...
                                            2 7 11 10;...
                                            7 8 12 11;...
                                            1 8 12 9;...
                                            4 3 10 9;...
                                            3 6 11 10;...
                                            6 5 12 11;...
                                            4 5 12 9;...
                                            3 4 13 14;...
                                            3 6 15 14;...
                                            4 5 16 13;...
                                            6 5 16 15;...
                                            13 14 18 17;...
                                            14 15 19 18;...
                                            15 16 20 19;...
                                            16 13 17 20;...
                                            17 18 22 21;...
                                            18 19 23 22;...
                                            19 20 24 23;...
                                            20 17 21 24];
                                        
                                        %defining the frames for the buildings
                                        
                                        %xcoords for north,south,east and west faces for
                                        x_n = [x4,x3,x3,x4,x4];
                                        x_s = [x1,x2,x2,x1,x1];
                                        x_e = [x3,x2,x2,x3,x3];
                                        x_w = [x4,x1,x1,x4,x4];
                                        x_c = [x1in,x2in,x3in,x4in,x1in];
                                        %ycoords
                                        y_n = [y4,y3,y3,y4,y4];
                                        y_s = [y1,y2,y2,y1,y1];
                                        y_e = [y3,y2,y2,y3,y3];
                                        y_w = [y4,y1,y1,y4,y4];
                                        y_c = [y1in,y2in,y3in,y4in,y1in];
                                        
                                        %zcoords
                                        z = [zfo,zfo,zfo+roof_frac*height,zfo+roof_frac*height,zfo];
                                        z_c = [zfo,zfo,zfo,zfo,zfo];
                                        %this will plot the frame of the buildings
                                        pc(1) = plot3(x_s,y_s,z);
                                        pc(2) = plot3(x_e,y_e,z);
                                        pc(3) = plot3(x_n,y_n,z);
                                        pc(4) = plot3(x_w,y_w,z);
                                        pc(5) = plot3(x_c,y_c,z_c);
                                        pc(6) = plot3([x1,x1in],[y1,y1in],[zfo+roof_frac*height,zfo]);
                                        pc(7) = plot3([x2,x2in],[y2,y2in],[zfo+roof_frac*height,zfo]);
                                        pc(8) = plot3([x3,x3in],[y3,y3in],[zfo+roof_frac*height,zfo]);
                                        pc(9) = plot3([x4,x4in],[y4,y4in],[zfo+roof_frac*height,zfo]);
                                        pc(10) = plot3(x_c,y_c,z_c+height);
                                    end;
%                                 else
%                                     v = [x1, y1;...
%                                         x2, y2;...
%                                         x3, y3;...
%                                         x4, y4;...
%                                         x1, y1;...
%                                         NaN, NaN;...
%                                         x1in, y1in;...
%                                         x2in, y2in;...
%                                         x3in, y3in;...
%                                         x4in, y4in;...
%                                         x1in, y1in];
%                                     f=[1,2,3,4,5,11,10,9,8,7,1];
%                                 end;
                                set(pc,'tag','BuildFrame');
                                xnum_loc = xfo+strct_length*cos(gamma)*0.5;
                                ynum_loc = yfo+strct_length*sin(gamma)*0.5;
                            case 5;
                                xc = xfo+0.5*strct_length*cos(gamma); %location of blding num
                                yc = yfo+0.5*strct_length*sin(gamma);
                                xr = strct_length*0.5;%major/minor radius
                                yr = width*0.5;%major/minor radius
                                if roofflag;
                                    roof_frac=0.8;
                                else
                                    roof_frac=1;
                                end;
                                %this will produce 3 matrices that are 25 X 2 both rows of x1 and y1
                                %will have the exact same values.  x1 and y1 will produce a circle. z1 is
                                %just zeros and ones I am throwing out the z1 values anyways, because they
                                %are useless to me.  this will be a unit circle.
                                n=24;%this is and even number vetices around the circle
                                [xcyl,ycyl,z] = cylinder(1,n);
                                
                                %if I multipy the values by their actual radii and add the ellipse center
                                %value then it will produce an ellipse.
                                x = xcyl(1,:)*xr*cos(gamma)-ycyl(1,:)*yr*sin(gamma)+xc;
                                y = xcyl(1,:)*xr*sin(gamma)+ycyl(1,:)*yr*cos(gamma)+yc;
                                xin = xcyl(1,:)*(xr-wallthickness)*cos(gamma)-ycyl(1,:)*(yr-wallthickness)*sin(gamma)+xc;
                                yin = xcyl(1,:)*(xr-wallthickness)*sin(gamma)+ycyl(1,:)*(yr-wallthickness)*cos(gamma)+yc;
%                                 if param.threed;
                                    z = z*(zfo+height*roof_frac);
                                    if roofflag<0.5;
                                        v=zeros(3*n,3);
                                        for j=1:n
                                            %the bottom vertices
                                            v(j,1) = x(1,j);
                                            v(j,2) = y(1,j);
                                            v(j,3) = zfo;
                                            %the top vertices
                                            v(j+n,1) = x(1,j);
                                            v(j+n,2) = y(1,j);
                                            v(j+n,3) = zfo+height*roof_frac;
                                            %the center verticies
                                            v(j+2*n,1) = xin(1,j);
                                            v(j+2*n,2) = yin(1,j);
                                            v(j+2*n,3) = zfo;
                                        end
                                        
                                        % Defining the vertical faces
                                        f=zeros(2*n,4);
                                        for j=1:n-1
                                            f(j,1) = j;
                                            f(j,2) = j+1;
                                            f(j,3) = j+n+1;
                                            f(j,4) = j+n;
                                        end
                                        f(n,1) = n;
                                        f(n,2) = 1;
                                        f(n,3) = n+1;
                                        f(n,4) = 2*n;
                                        
                                        %the top of the cylinder
                                        for j=n+1:2*n-1
                                            f(j,1) = j;
                                            f(j,2) = j+1;
                                            f(j,3) = j+n+1;
                                            f(j,4) = j+n;
                                        end
                                        f(2*n,1) = 3*n;
                                        f(2*n,2) = 2*n+1;
                                        f(2*n,3) = n+1;
                                        f(2*n,4) = 2*n;
                                        
                                        %this will only plot the circle/ellipse edge on top so the user can
                                        %see the edge better
                                        pc(1) = plot3(x(1,:),y(1,:),z(1,:));
                                        pc(2) = plot3(x(1,:),y(1,:),z(2,:));
                                        pc(3) = plot3(xin(1,:),yin(1,:),z(1,:));
                                    else
                                        xroof(1,:) = xcyl(1,:)*(xr-(wallthickness*(1/3)^2))*cos(gamma)-ycyl(1,:)*(yr-(wallthickness*(1/3)^2))*sin(gamma)+xc;
                                        yroof(1,:) = xcyl(1,:)*(xr-(wallthickness*(1/3)^2))*sin(gamma)+ycyl(1,:)*(yr-(wallthickness*(1/3)^2))*cos(gamma)+yc;
                                        xroof(2,:) = xcyl(1,:)*(xr-(wallthickness*(2/3)^2))*cos(gamma)-ycyl(1,:)*(yr-(wallthickness*(2/3)^2))*sin(gamma)+xc;
                                        yroof(2,:) = xcyl(1,:)*(xr-(wallthickness*(2/3)^2))*sin(gamma)+ycyl(1,:)*(yr-(wallthickness*(2/3)^2))*cos(gamma)+yc;
                                        z_roof(1)=zfo+height*(roof_frac+(1-roof_frac)*(1/3));
                                        z_roof(2)=zfo+height*(roof_frac+(1-roof_frac)*(2/3));
                                        z_roof(3)=zfo+height;
                                        v=zeros(6*n,3);
                                        for j=1:n
                                            %the bottom vertices
                                            v(j,1) = x(1,j);
                                            v(j,2) = y(1,j);
                                            v(j,3) = zfo;
                                            %the top vertices
                                            v(j+n,1) = x(1,j);
                                            v(j+n,2) = y(1,j);
                                            v(j+n,3) = zfo+height*roof_frac;
                                            %roof verticies
                                            v(j+2*n,1) = xroof(1,j);
                                            v(j+2*n,2) = yroof(1,j);
                                            v(j+2*n,3) = z_roof(1);
                                            v(j+3*n,1) = xroof(2,j);
                                            v(j+3*n,2) = yroof(2,j);
                                            v(j+3*n,3) = z_roof(2);
                                            v(j+4*n,1) = xin(1,j);
                                            v(j+4*n,2) = yin(1,j);
                                            v(j+4*n,3) = z_roof(3);
                                            %the center verticies
                                            v(j+5*n,1) = xin(1,j);
                                            v(j+5*n,2) = yin(1,j);
                                            v(j+5*n,3) = zfo;
                                        end
                                        
                                        % Defining the vertical faces and roof
                                        f=zeros(5*n,4);
                                        for jj=1:4;
                                            for j=((jj-1)*n)+1:(jj*n)-1
                                                f(j,1) = j;
                                                f(j,2) = j+1;
                                                f(j,3) = j+n+1;
                                                f(j,4) = j+n;
                                            end
                                            f(jj*n,1) = jj*n;
                                            f(jj*n,2) = (jj-1)*n+1;
                                            f(jj*n,3) = jj*n+1;
                                            f(jj*n,4) = (jj+1)*n;
                                        end;
                                        
                                        %stands of stadium
                                        for j=4*n+1:5*n-1
                                            f(j,1) = j+n;
                                            f(j,2) = j+n+1;
                                            f(j,3) = j-3*n+1;
                                            f(j,4) = j-3*n;
                                        end
                                        f(5*n,1) = 6*n;
                                        f(5*n,2) = 5*n+1;
                                        f(5*n,3) = n+1;
                                        f(5*n,4) = 2*n;
                                        
                                        %this will only plot the circle/ellipse edge on top so the user can
                                        %see the edge better
                                        pc(1) = plot3(x(1,:),y(1,:),z(1,:));
                                        pc(2) = plot3(x(1,:),y(1,:),z(2,:));
                                        pc(3) = plot3(xin(1,:),yin(1,:),z(1,:));
                                        pc(4) = plot3(xin(1,:),yin(1,:),z(1,:)+height);
                                    end;
%                                 else
%                                     v=zeros(2*n+1,2)*NaN;
%                                     for j=1:n
%                                         v(j,1) = x(1,j);
%                                         v(j,2) = y(1,j);
%                                         v(j+n+1,1) = xin(1,j);
%                                         v(j+n+1,2) = yin(1,j);
%                                     end;
%                                     f=[(1:n),(2*n+1:-1:n+2),1];
%                                     pc=plot(v(:,1),v(:,2));
%                                 end;
                                set(pc,'tag','BuildFrame');
                                xnum_loc = xfo+strct_length*cos(gamma)*0.5;
                                ynum_loc = yfo+strct_length*sin(gamma)*0.5;
                            case 6;
                                xc=bld(i).xc;
                                yc=bld(i).yc;
                                x=bld(i).x;
                                y=bld(i).y;
                                nfaces=length(x)-length(find(isnan(x)))*2;
                                x=x(~isnan(x));
                                y=y(~isnan(y));
%                                 if param.threed;
                                    z=zeros(2,length(x));
                                    z(1,:)=0*x+zfo;
                                    z(2,:)=0*x+zfo+height;
                                    v=zeros(nfaces*4,3);
                                    f=zeros(nfaces,4);
                                    ivert=1;
                                    iface=1;
                                    k=1;
                                    startpoly=1;
                                    xvals=zeros(1,5);
                                    yvals=xvals;
                                    zvals=xvals;
                                    while ivert<length(x);
                                        f(iface,1)=k;
                                        v(k,1)=x(ivert);
                                        v(k,2)=y(ivert);
                                        v(k,3)=z(1,ivert);
                                        xvals([1,5])=v(k,1);
                                        yvals([1,5])=v(k,2);
                                        zvals([1,5])=v(k,3);
                                        k=k+1;
                                        f(iface,2)=k;
                                        v(k,1)=x(ivert+1);
                                        v(k,2)=y(ivert+1);
                                        v(k,3)=z(1,ivert+1);
                                        xvals(2)=v(k,1);
                                        yvals(2)=v(k,2);
                                        zvals(2)=v(k,3);
                                        k=k+1;
                                        f(iface,3)=k;
                                        v(k,1)=x(ivert+1);
                                        v(k,2)=y(ivert+1);
                                        v(k,3)=z(2,ivert+1);
                                        xvals(3)=v(k,1);
                                        yvals(3)=v(k,2);
                                        zvals(3)=v(k,3);
                                        k=k+1;
                                        f(iface,4)=k;
                                        v(k,1)=x(ivert);
                                        v(k,2)=y(ivert);
                                        v(k,3)=z(2,ivert);
                                        xvals(4)=v(k,1);
                                        yvals(4)=v(k,2);
                                        zvals(4)=v(k,3);
                                        k=k+1;
                                        pc(iface)=plot3(xvals,yvals,zvals);
                                        iface=iface+1;
                                        if x(ivert+1)==x(startpoly) & y(ivert+1)==y(startpoly);
                                            ivert=ivert+2;
                                            startpoly=ivert;
                                        else
                                            ivert=ivert+1;
                                        end;
                                    end;
                                    nans=find(isnan(bld(i).x));
                                    if length(nans)>1;
                                        x=bld(i).x;
                                        y=bld(i).y;
                                        for iface=length(nans)-1:-1:1;
                                            x=[x,x(nans(iface)-1)];
                                            y=[y,y(nans(iface)-1)];
                                        end;
                                        x=x(~isnan(x));
                                        y=y(~isnan(y));
                                        z=zeros(2,length(x));
                                        z(1,:)=0*x+zfo;
                                        z(2,:)=0*x+zfo+height;
                                    end;
                                    v=v(v(:,1)>0,:);
                                    f=f(f(:,1)>0,:);
%                                 else
%                                     v=zeros(nfaces*4,2);
%                                     f=zeros(nfaces,4);
%                                     ivert=1;
%                                     iface=1;
%                                     k=1;
%                                     startpoly=1;
%                                     while ivert<length(x);
%                                         f(iface,1)=k;
%                                         v(k,1)=x(ivert);
%                                         v(k,2)=y(ivert);
%                                         k=k+1;
%                                         f(iface,2)=k;
%                                         v(k,1)=x(ivert+1);
%                                         v(k,2)=y(ivert+1);
%                                         k=k+1;
%                                         f(iface,3)=k;
%                                         v(k,1)=x(ivert+1);
%                                         v(k,2)=y(ivert+1);
%                                         k=k+1;
%                                         f(iface,4)=k;
%                                         v(k,1)=x(ivert);
%                                         v(k,2)=y(ivert);
%                                         k=k+1;
%                                         iface=iface+1;
%                                         if x(ivert+1)==x(startpoly) & y(ivert+1)==y(startpoly);
%                                             ivert=ivert+2;
%                                             startpoly=ivert;
%                                         else
%                                             ivert=ivert+1;
%                                         end;
%                                     end;
%                                     pc=plot(bld(i).x,bld(i).y);
%                                     v=v(v(:,1)>0,:);
%                                     f=f(f(:,1)>0,:);
%                                 end;
                                if type == 2;
                                    set(pc,'tag','VegFrame');
                                else
                                    set(pc,'tag','BuildFrame');
                                end;
                                xnum_loc = xc;
                                ynum_loc = yc;
                        end
                        set(pc,'hittest','off');
                        if isequal(bldnfo.colordef,'constant')
                            bld_color = bldnfo.color;
                        else
                            %this will adjust the colormap range so that the
                            %tallest building is the color of the 64th index of the
                            %current colormap
                            cmap = str2cmap(bldnfo.colormap);
                            % JENNY - 12/1/05 <--
                            if type == 1 | type == 4 | type == 5;%if it's a building or a bridge
                                if diff_height ~= 0
                                    bld_color = cmap(ceil(((zfo+height)-min_height)*64/diff_height),:);
                                else
                                    bld_color = cmap(1,:);
                                end
                            end
                            % JENNY - 12/1/05 <--
                        end

                        % JENNY - 12/1/05 -->
                        switch type;
                            case 2; 
                                set(pc,'color',[0 1 .2]);   %For vegetations (slightly blue-green)
                            case 3;
                                set(pc,'color',[.2 .2 .2]);   %For garages (grey)
                            %~ case 1;
                                %~ set(pc,'color',bld_color);  %For buildings
                            %~ otherwise %if it's a bld
                                %~ set(pc,'color',[.2 .2 .2]);  %For relief (grey)
                            otherwise %if it's a bld or RELIEF
                                set(pc,'color',bld_color);  %For buildings AND RELIEF    
                        end;
                        switch type;
                            case 2;
                                if param.veg;
%                                     if param.threed;
                                        p = patch('Vertices',v,'Faces',f);
                                        set(p,'tag','VegPatch','hittest','off');
                                        set(p,'FaceColor','g','EdgeColor','g');
                                        if geometry==6;
                                            p = fill3(x,y,z(2,:),'g');
                                            set(p,'tag','VegPatch');
                                            set(p,'FaceColor','g','EdgeColor','g','hittest','off');
                                        end;
                                        if plotbldnums;
                                            textnum = text(xnum_loc,ynum_loc,zfo+height+ceil(3/height),num2str(i));
                                            set(textnum,'tag','BuildNums','hittest','off');
                                        end;
%                                     else
%                                         if geometry==6;
%                                             p = fill(x,y,'g');
%                                         else
%                                             p = patch('Vertices',v,'Faces',f);
%                                         end;
%                                         set(p,'tag','VegPatch');
%                                         set(p,'FaceColor','g','EdgeColor','g');
%                                         if plotbldnums;
%                                             textnum = text(xnum_loc,ynum_loc,num2str(i));
%                                             set(textnum,'tag','BuildNums');
%                                         end;
%                                     end;
                                else
                                    if ishandle(vegpatch)
                                        set(vegpatch,'visible','off');
                                    end
                                    if ishandle(pc);
                                        set(pc,'visible','off');
                                    end;
                                end
                            otherwise;
                                % JENNY - 12/1/05 <--
                                if param.bld;
                                    %this creates the building
%                                     if param.threed;
                                        p = patch('Vertices',v,'Faces',f);
                                        % JENNY - 12/1/05 -->
                                        switch type;
                                            case 4 % For garages
                                                set(p,'tag','GaragePatch');
                                                set(p,'FaceColor',[.8 .8 .8],'EdgeColor','k');
                                            otherwise % For Buildings
                                                set(p,'tag','BuildPatch');
                                                set(p,'FaceColor',bld_color,'EdgeColor','none');
                                        end;
                                        if geometry==6;
                                            p = fill3(x,y,z(2,:),'k');
                                            switch type;
                                                case 4 % For garages
                                                    set(p,'tag','GaragePatch');
                                                    set(p,'FaceColor',[.8 .8 .8],'EdgeColor','k');
                                                otherwise % For Buildings
                                                    set(p,'tag','BuildPatch');
                                                    set(p,'FaceColor',bld_color,'EdgeColor','none');
                                            end;
                                        end;
                                        set(p,'hittest','off');
%                                     else
%                                         if geometry==6;
%                                             p = fill(x,y,'k');
%                                         else
%                                             p = patch('Vertices',v,'Faces',f);
%                                         end;
%                                         switch type;
%                                             case 4 % For garages
%                                                 set(p,'tag','GaragePatch');
%                                                 set(p,'FaceColor',[.8 .8 .8],'EdgeColor','k');
%                                             otherwise % For Buildings
%                                                 set(p,'tag','BuildPatch');
%                                                 set(p,'FaceColor',bld_color,'EdgeColor','none');
%                                         end;
%                                     end;
                                    % JENNY - 12/1/05 <--
                                    %this sets the building color depending on height
                                    %with an index into the chosen colormap
                                    %If the option of picking the building color is chosen then they will
                                    %all be the same color
                                    %edge color is set to none first so the circle buildings don't
                                    %have a ton of stripes running down the sides
                                    %numbering the buildings
                                    if plotbldnums;
%                                         if param.threed;
                                            if param.grid.outer_flag
                                                textnum = text(xnum_loc,ynum_loc,zfo+height+ceil(3/height),num2str(i));
                                            else
                                                textnum = text(xnum_loc,ynum_loc,zfo+height+ceil(3/height),num2str(i));
                                            end
%                                         else
%                                             if param.grid.outer_flag
%                                                 textnum = text(xnum_loc,ynum_loc,num2str(i));
%                                             else
%                                                 textnum = text(xnum_loc,ynum_loc,num2str(i));
%                                             end
%                                         end;
                                        set(textnum,'tag','BuildNums','hittest','off');
                                    end;
                                else
                                    % JENNY - 10/14/05 -->
                                    if ishandle(buildpatch)
                                        set(buildpatch,'visible','off');
                                    end
                                    if ishandle(garagepatch)
                                        set(garagepatch,'visible','off');
                                    end
                                    % JENNY - 10/14/05 <--
                                end %nobld
                        end;
                    end %for loop for buildings
                end;
            end;
        end %isempty
    else
        %this is the function that uses the celltype2 data for plotting
        %the buildings when input.dat is not available or is in an
        %incorrect form
%         if param.threed;
            fv=isosurface(param.celltype.x,param.celltype.y,param.celltype.z,param.celltype.c,.9);
            p=patch(fv);
%         else
%             buildingcells=ones(domain.y,domain.x)*NaN;
%             for i=1:domain.x;
%                 for j=1:domain.y;
%                     if param.celltype.c(j,i,2)==0;
%                         buildingcells(j,i)=1;
%                     end;
%                 end;
%             end;
%             p=pcolor(param.celltype.x(:,:,1),param.celltype.y(:,:,1),buildingcells);
%         end;
        set(p,'FaceColor','yellow','EdgeColor','none','hittest','off'); %modify patches
        %[p,d] = quic2mat3(param.quic2mat);
        set(p,'tag','BuildPatch');
        if ~param.bld
            set(p,'visible','off')
        end
        x=unique(param.celltype.x);
        y=unique(param.celltype.y);
        z=unique(param.celltype.z);
        domain.x = length(x);
        domain.y = length(y);
        domain.z = length(z)-1;
        domain.dx=x(2)-x(1);
        domain.dy=y(2)-y(1);
        domain.dz=z(2)-z(1);
        %then plot some ground
        xmin = 0;
        ymin = 0;
        zmin = -0.5*domain.dz;
        zmax = 0;
        xmax = domain.x*domain.dx;
        ymax = domain.y*domain.dy;
        %defining every vertex and face to be plotted for the ground
        v = [xmin ymin zmin;xmax ymin zmin;xmax ymin zmax;...
            xmin ymin zmax;xmin ymax zmax;xmax ymax zmax;...
            xmax ymax zmin;xmin ymax zmin;];
        f = [1 2 3 4;2 7 6 3;7 8 5 6;8 1 4 5;4 3 6 5;1 2 7 8];
        ground = patch('Vertices',v,'Faces',f,'facecolor',[0 .5 0]);
        %plot the canopy if it has one and if the canopy plotting
        %function is in this directory
        if exist(fullfile(param.quic2mat,'canopy.dat'),'file') && exist(fullfile(cd,'canopyplot.m'),'file')
            canopyplot(param.quic2mat);
        end
    end %quic2mat
end%if replot and ishandle(bld_patch)
if param.replot

    %TMB 7/14/03
    %for scaling purposes the axis labels are changed to make the buildings
    %appear to have been scaled to the correct size
    grid on

    %turning off the matlab default ticklabels
    if ~param.quic2mat;
        set(gca,'xticklabel','','yticklabel','','zticklabel','')
    end;



    %plotting the tickmarks and labels
    if param.tick

        %setting the tick marks to divide the domain in fifths
        dx = round(domain.dx*1000*domain.x/5)/1000;
        dy = round(domain.dy*1000*domain.y/5)/1000;
        dz = round(domain.dz*1000*domain.z/5)/1000;


        %creating a vector of axes labels
        x = 0:dx:domain.x*domain.dx;
        y = 0:dy:domain.y*domain.dy;
        z = dz:dz:domain.z_array(end);%removed 0



        xtick = (x);
        ytick = (y);
        ztick = (z);


        set(gca,'xtick',x,'ytick',y,'ztick',z);
        tx=0*x;
        ty=0*y;
        tz=0*z;
        if ~param.quic2mat;
            if param.xtick
                for i=1:length(x)
                    tx(i) = text(x(i),0,0,num2str(xtick(i)),...
                        'verticalalignment','bottom','horizontalalignment','center',...
                        'tag','CityAxes');
                end
            end
            if param.ytick
                for i=1:length(y)
                    ty(i) = text(0,y(i),0,num2str(ytick(i)),...
                        'verticalalignment','bottom','horizontalalignment','center',...
                        'tag','CityAxes');
                end
            end
            if param.ztick
                for i=1:length(z)
                    tz(i) = text(0,0,z(i),num2str(ztick(i)),...
                        'verticalalignment','middle','horizontalalignment','left',...
                        'tag','CityAxes');
                end
            end
        end;
    end

    %plotting origin axes
    if param.axes
        adx = min([domain.z_array(end),domain.y*domain.dy,domain.x*domain.dx]);
        adx = adx/5;

        %plotting the origin axes
%         if param.threed;
            axisz = plot3([0,0],[0,0],[0,adx],'b','linewidth',2);
            axisy = plot3([0,0],[0,adx],[0,0],'g','linewidth',2);
            axisx = plot3([0,adx],[0,0],[0,0],'r','linewidth',2);
            set([axisz,axisy,axisx],'tag','CityAxes');
%         else
%             axisy = plot([0,0],[0,adx],'g','linewidth',2);
%             axisx = plot([0,adx],[0,0],'r','linewidth',2);
%             set([axisy,axisx],'tag','CityAxes');
%         end;
    end


    % set(gca,'color','none');%making the background axis color invisible
    % set(city3d,'color','white'); %making the figure background white
    %     set(gcf,'Renderer','opengl');%setting the renderer to opengl which is the best


    daspect([1 1 1]);%for the correct aspect ratio
    material shiny%options shiny, metal, dull

    if param.threed
        view(3)
        light  %so the light is in the correct place
        camlight%and the camlight too

        %this gets the default view the first time that the city is plotted
        %this will not interfere with tims default view because his will be
        %defined after this one so it will erase this ones data
        d_view.pos = get(gca,'CameraPosition');
        d_view.target = get(gca,'CameraTarget');
        d_view.upvector = get(gca,'CameraUpVector');

        view(param.az,param.el)%change the view to what it was before the plots,if a figure exsisted
        lighting gouraud; % phong, gouraud, and flat are the options.
    else
        view(2)
        
        %this gets the default view the first time that the city is plotted
        %this will not interfere with tims default view because his will be
        %defined after this one so it will erase this ones data
        d_view.pos = get(gca,'CameraPosition');
        d_view.target = get(gca,'CameraTarget');
        d_view.upvector = get(gca,'CameraUpVector');
        lighting flat; % phong, gouraud, and flat are the options.
    end

    %this tells AlignView.m what the default view will be
    set(gca,'userdata',d_view);

    

    if param.ortho
        camproj('orthographic');
    else
        camproj('perspective'); %gives a perspective view of the plot
    end

    xlabel('X')%labeling axis
    ylabel('Y')
    if param.threed
    zlabel('Z')
    end;
    %     axis manual
%     if param.threed
        axis([0 domain.x*domain.dx 0 domain.y*domain.dy zmin domain.z_array(end)]);
        axis vis3d%keeps the 3D plot from moving in and out when spinning it
        axis fill
%     else
%         axis([0 domain.x*domain.dx 0 domain.y*domain.dy]);
%     end;
else
    lighting gouraud % phong, gouraud, and flat are the options.
end %blank



%this turns the axes on or off if it's specified through the cityoptions or
%a toggle button
atoggle = findobj(fighandle,'tag','axistoggle');
cityaxes = findobj(fighandle,'tag','CityAxes');
if strcmp(gndnfo.axes,'on')
    set(cityaxes,'visible','on');
    set(atoggle,'state','on');
else
    set(cityaxes,'visible','off');
    set(atoggle,'state','off');
end

%this is the transparency of the buildings
% JENNY - 12/1/05 -->
bldpatch = findobj(fighandle,'tag','BuildPatch');
vegpatch = findobj(fighandle,'tag','VegPatch');

set(vegpatch,'facealpha',.3);

if strcmp(bldnfo.transparent,'on')
    set(bldpatch,'facealpha',.5);
else
    set(bldpatch,'facealpha',1);
end

hold off

% JENNY - 12/1/05 <--

% this plots and animates the sensors
if (param.sensor(1).data{1}(1,1) >= 0)

    skycolor = [ 0.6118    0.7216    0.9804];
    %     skycolor =[ 0.800 0.855 0.992 ];
    set(gca,'color',skycolor)
    %   set up the x,y and z data for the 3D sensors to be plotted
    %   default image data is centered at origin and will be shifted for each
    %   sensor in the for loop below
    % First define vane image
    vane    = imread(fullfile('images','weather_vane.bmp'));
    % set alphadata to 0 where image is white and 1 elsewhere
    vane_alpha = vane(:,:,1);
    vane_alpha(vane(:,:,1)<255 & vane(:,:,2)<255 & vane(:,:,3)<255) = 200;
    vane_alpha(vane(:,:,1)==255 & vane(:,:,2)==255 & vane(:,:,3)==255) = 0;
    vane_alpha(vane_alpha==200) = 1;
    % points defining standard triangular tower centered at origin,
    side = (2/3);  %side is 2/3 of cell wide
    center_length = side*sin((60*pi)/180);
    count = 1;
    tower_faces = [1 2 3 1];
    % define points, faces, and color for the single sensor tower (patch)
    for z = 0:((1/3)):domain.z%*domain.dz
        tower_pts(count:count+2,:) = [side*0.5,  -center_length*0.5,  z;...
            0,        center_length*0.5,  z;...
            -side*0.5, -center_length*0.5,  z];

        tower_faces(count+1:count+3,:) = [count   count+4 count+3 count;...
            count+1 count+5 count+4 count+1;...
            count+2 count+3 count+5 count+2];
        color = [1 1 1];
        if rem(floor(z/5),2)==0
            color = [1 0 0];
        end
        tower_color(count:count+2,1:3) = [color;color;color];
        count = count+3;
    end
    % x,y and z data for surface (centered at origin) used for vane image
    x = [];y = [];z = [];
    x_vane(size(vane,1),size(vane,2)) = 0;
    vane_scale = 3;
    [y,z] = meshgrid(((vane_scale*35)/28):(-vane_scale*35)/(28*size(vane,2)):...
        (vane_scale*35)/(28*size(vane,2)),vane_scale:-vane_scale/size(vane,1):vane_scale/size(vane,1));
    y_vane = y + 22*(y(1,2)-y(1,1));
    z_vane = z - 14*(z(2)-z(3));

    %create propeller x,y and z data for standard vane
    x = [];y = [];z = [];
    prop_color = [0.5 0.5 0.5];
    y = [0; 0; 0; 0];
    x = [0; 0; vane_scale*0.5; vane_scale*0.5];
    z = [-vane_scale/12; vane_scale/12; vane_scale/9; -vane_scale/9];
    [x,y,z] = rotate_object_data(x,y,z,[1 0 0],-20,[0 0 0]);
    x_prop = x; y_prop = y; z_prop = z;
    % create image of propeller blade every 20 degrees
    for angle = 0:30:330
        [x,y,z] = rotate_object_data(x,y,z,[0 1 0],angle,[0 0 0]);
        x_prop = [x_prop, x]; %#ok<AGROW>
        y_prop = [y_prop, y]; %#ok<AGROW>
        z_prop = [z_prop, z]; %#ok<AGROW>
    end

    x = [];y = [];z = [];
    [x,y,z] = sphere(40); % unit ball
    balloon_x = x;
    balloon_y = y; balloon_y(balloon_y>0) = balloon_y(balloon_y>0)*2.5; % stretch ball in y dir
    balloon_z = z;
    % create default fins for balloon from unit sphere
    fin_x = 0.3*x;
    fin_y = y; fin_y(fin_y>0) = fin_y(fin_y>0)*2; fin_y = fin_y*0.75;
    fin_z = z; fin_z = fin_z*0.75;
    [topfin_x topfin_y topfin_z]       = rotate_object_data(fin_x,fin_y,fin_z,[1 0 0],60,[0 0 0]);
    [botfin_x botfin_y botfin_z]       = rotate_object_data(fin_x,fin_y,fin_z,[1 0 0],-60,[0 0 0]);
    [sidefin_x sidefin_y sidefin_z]    = rotate_object_data(fin_x,fin_y,fin_z,[0 1 0],90,[0 0 0]);
    [leftfin_x leftfin_y leftfin_z]    = rotate_object_data(sidefin_x,sidefin_y,sidefin_z,[0 0 1],60,[0 0 0]);
    [rightfin_x rightfin_y rightfin_z] = rotate_object_data(sidefin_x,sidefin_y,sidefin_z,[0 0 1],-60,[0 0 0]);
    topfin_y = topfin_y+1.75; botfin_y = botfin_y+1.75; leftfin_y = leftfin_y+1.75; rightfin_y = rightfin_y+1.75;
    balloon_color = [255 128 0]/255;
    balloon_path_z = [];
    sensor_length  = [];
    if param.grid.outer_flag
        hold on
        %plot domain boundry for inner grid
        plot3([0,0,param.grid.domain_inner.x*param.grid.domain_inner.dx,param.grid.domain_inner.x*param.grid.domain_inner.dx,0]...
            +param.grid.in_grid_loc.x,[0,param.grid.domain_inner.y*param.grid.domain_inner.dy,param.grid.domain_inner.y*param.grid.domain_inner.dy,0,0]...
            +param.grid.in_grid_loc.y,[0,0,0,0,0],'red')

        %             text(param.grid.domain_inner.x*param.grid.domain_inner.dx/2+param.grid.in_grid_loc.x,...
        %                 param.grid.domain_inner.y*param.grid.domain_inner.dy+param.grid.in_grid_loc.y,0,'Inner Grid',...
        %                 'horizontalalignment','center','color','red');
        %             text(param.grid.domain_inner.x*param.grid.domain_inner.dx+param.grid.in_grid_loc.x,...
        %                 param.grid.domain_inner.y*param.grid.domain_inner.dy/2+param.grid.in_grid_loc.y,0,'Inner Grid','rotation',-90,...
        %                 'horizontalalignment','center','color','red');
        %             text(param.grid.domain_inner.x*param.grid.domain_inner.dx/2+param.grid.in_grid_loc.x,...
        %                 param.grid.in_grid_loc.y,0,'Inner Grid',...
        %                 'horizontalalignment','center','color','red');
        %             text(param.grid.in_grid_loc.x,param.grid.domain_inner.y*param.grid.domain_inner.dy/2+param.grid.in_grid_loc.y,0,'Inner Grid','rotation',-90,...
        %                 'horizontalalignment','center','color','red');
    end
    %         hold on
    %         plot3([0,0,param.grid.domain_inner.x*param.grid.domain_inner.dx,param.grid.domain_inner.x*param.grid.domain_inner.dx,0]...
    %                 +param.grid.in_grid_loc.x,[0,param.grid.domain_inner.y*param.grid.domain_inner.dy,param.grid.domain_inner.y*param.grid.domain_inner.dy,0,0]...
    %                 +param.grid.in_grid_loc.y,[0,0,0,0,0],'red')
    % create all sensor objects at initial position
    for i = 1:length(param.sensor)
        if param.sensor(i).blflag < 4      % point sensor
            sensor_length(end+1) = size(param.sensor(i).data{1},1); %#ok<AGROW>
            point_sensors(end+1) = i; %#ok<AGROW>
            numofpoints = round(((9*param.sensor(i).data{1}(1,1)/domain.dz))+3);
            vert  = tower_pts;
            vert(:,1) = vert(:,1) + param.sensor(i).x;%domain.dx;
            vert(:,2) = vert(:,2) + param.sensor(i).y;%domain.dy;
            tower_object = patch('vertices',vert(1:numofpoints-6,:),...
                'faces',   tower_faces(1:(numofpoints-8),:),...
                'edgecolor','flat',...
                'facecolor','none',...
                'facevertexcdata',tower_color(1:numofpoints-6,:),...
                'tag','sensor_tower',...
                'linewidth',1);
            angle_idx = 1;
            [xdata_vane, ydata_vane, zdata_vane] = rotate_object_data(x_vane,y_vane,z_vane,[0 0 1],-param.sensor(i).data{1}(1,2),[0 0 0]);
            %                 vane_object = surface(xdata_vane+param.sensor(i).x/domain.dx,...
            %                     ydata_vane+param.sensor(i).y/domain.dy,...
            %                     zdata_vane+param.sensor(i).z/domain.dz,vane,...
            vane_object = surface(xdata_vane+param.sensor(i).x,...
                ydata_vane+param.sensor(i).y,...
                zdata_vane+param.sensor(i).data{1}(1,1),vane,...
                'alphadata',vane_alpha,'facealpha','texturemap',...
                'edgecolor','none','tag',['vane',param.sensor(i).name],...
                'facecolor','texturemap','userdata',angle_idx);
            [xdata_prop, ydata_prop, zdata_prop] = rotate_object_data(x_prop, y_prop, z_prop,[0 0 1],-param.sensor(i).data{1}(1,2),[0 0 0]);
            %                 propellar_object = patch('xdata',xdata_prop+param.sensor(i).x/domain.dx,...
            %                     'ydata',ydata_prop+param.sensor(i).y/domain.dy,...
            %                     'zdata',zdata_prop+param.sensor(i).z/domain.dz,...
            propellar_object = patch('xdata',xdata_prop+param.sensor(i).x,...
                'ydata',ydata_prop+param.sensor(i).y,...
                'zdata',zdata_prop+param.sensor(i).data{1}(1,1),...
                'facecolor',prop_color,...
                'edgecolor',[0.3 0.3 0.3],...
                'tag',['propeller',param.sensor(i).name],...
                'userdata',param.sensor(i).data{1}(1,2));
        else% sounding
            balloon_path_x = []; %reset
            balloon_path_y = [];
            balloon_path_z = [];
            balloon_path_z = param.sensor(i).data{1}(:,1)';%/domain.dz;
            balloon_path_x(1:length(balloon_path_z)) = param.sensor(i).x;%/domain.dx;
            balloon_path_y(1:length(balloon_path_z)) = param.sensor(i).y;%/domain.dy;
            %             sounding_line = line(balloon_path_x,balloon_path_y,balloon_path_z,...
            %                 'linestyle','-','marker','*','color','k','linewidth',1);
            userdata.z = balloon_path_z;
            userdata.idx = 1;
            sensor_length(end+1) = length(balloon_path_z); %#ok<AGROW>
            x = [];y = [];z = [];
            %                 x = [balloon_x+param.sensor(i).x/domain.dx,...
            %                         rightfin_x+param.sensor(i).x/domain.dx,...
            %                         leftfin_x+param.sensor(i).x/domain.dx,...
            %                         topfin_x+param.sensor(i).x/domain.dx,...
            %                         botfin_x+param.sensor(i).x/domain.dx];
            %                 y = [balloon_y+param.sensor(i).y/domain.dy,...
            %                         rightfin_y+param.sensor(i).y/domain.dy,...
            %                         leftfin_y+param.sensor(i).y/domain.dy,...
            %                         topfin_y+param.sensor(i).y/domain.dy,...
            %                         botfin_y+param.sensor(i).y/domain.dy];
            %                 z = [balloon_z+balloon_path_z(1)/domain.dz,...
            %                         rightfin_z+balloon_path_z(1)/domain.dz,...
            %                         leftfin_z+balloon_path_z(1)/domain.dz,...
            %                         topfin_z+balloon_path_z(1)/domain.dz,...
            %                         botfin_z+balloon_path_z(1)/domain.dz];
            %                 balloon = surface(x,y,z,'tag',['balloon',param.sensor(i).name],...
            %                     'userdata',userdata,...
            %                     'edgecolor','none','facecolor',balloon_color);
            x = [balloon_x+param.sensor(i).x,...
                rightfin_x+param.sensor(i).x,...
                leftfin_x+param.sensor(i).x,...
                topfin_x+param.sensor(i).x,...
                botfin_x+param.sensor(i).x];
            y = [balloon_y+param.sensor(i).y,...
                rightfin_y+param.sensor(i).y,...
                leftfin_y+param.sensor(i).y,...
                topfin_y+param.sensor(i).y,...
                botfin_y+param.sensor(i).y];
            z = [balloon_z+balloon_path_z(1),...
                rightfin_z+balloon_path_z(1),...
                leftfin_z+balloon_path_z(1),...
                topfin_z+balloon_path_z(1),...
                botfin_z+balloon_path_z(1)];
            balloon = surface(x,y,z,'tag',['balloon',param.sensor(i).name],...
                'userdata',userdata,...
                'edgecolor','none','facecolor',balloon_color);
        end
    end
    [len,maxsensor_idx] = max(sensor_length);

    % animate the motion of the sensors
    animate_sensors(fighandle,param,domain,point_sensors,maxsensor_idx)


end


hold off



%--------------------------------------------------------------------------
function axistoggle(hObject,eventdata,fighandle)
%this function replots the city with or without the axes on

tggle = get(hObject,'state');

%getting the different pictures for the toggle positions
dwn = getappdata(fighandle,'AxisToggleDwn');
up = getappdata(fighandle,'AxisToggleUp');

%the handles to all the axes objects
cityaxes = findobj(fighandle,'tag','CityAxes');

if strcmp(tggle,'off')
    %     set(hObject,'cdata',up);
    set(cityaxes,'visible','off');
    cityplot_params('axes','off');
else
    %     set(hObject,'cdata',dwn);
    cityplot_params('axes','on');
    set(cityaxes,'visible','on');

end
%--------------------------------------------------------------------------
function ctb(hObject,eventdata,arg)
%this function allows the cameratoolbar to be edited from cityplot

switch arg
    case 'default'
        %just turn on default cameratoolbar with orbit on
        quicfigcameratoolbar;
    case 'nomode'
        %turn on cameratoolbar without orbit or any other function on
        quicfigcameratoolbar('show');
end

%--------------------------------------------------------------------------
function city_motion_fcn(obj,eventdata,fighandle,param,domain,point_sensors,maxsensor_idx)
if ishandle(fighandle)
    % currently_animating prevents matlab from keep calling animate_sensors
    % and surpassing the recursion limit
    currently_animating = getappdata(fighandle,'CurrentAnimationStatus');
    if  ~currently_animating
        animate_sensors(fighandle,param,domain,point_sensors,maxsensor_idx)
    end
end

%--------------------------------------------------------------------------
function animate_sensors(fighandle,param,domain,point_sensors,maxsensor_idx)
totaltime = param.sensortime;
laststatus = getappdata(fighandle,'CurrentAnimationStatus');
if isequal(gcf,fighandle)
    setappdata(fighandle,'CurrentAnimationStatus',1);
end
if ~laststatus
    mode = getappdata(fighandle,'LastCameratoolbarMode');
    quicfigcameratoolbar('setmode',mode)
end
pauseflag(1:length(param.sensor)) = 0;
pauseflag(point_sensors) = 1;
next_idx = [];
iter = 1;
while  isequal(gcf,fighandle)
    iter = iter+1;
    drawnow;
    % animate the spinning propeller on the vane sensors
    for s = 1:length(point_sensors)
        prop = findobj('tag',['propeller',param.sensor(point_sensors(s)).name]);
        normal_angle = get(prop,'userdata');
        normal_angle = -normal_angle+90;  % adjust for meteorological coord
        if ~ishandle(fighandle)
            return;
        end
        rotate(prop,[normal_angle,0],35,[param.sensor(point_sensors(s)).x,...
            param.sensor(point_sensors(s)).y param.sensor(point_sensors(s)).data{1}(1,1)]);
    end
    % animate the turning of the vane and the rising of the balloon sensor
    if rem(iter,round(20/length(param.sensor)))==0
        for i = 1:length(param.sensor)
            if ((next_idx==1) & (maxsensor_idx == i)) | isone(pauseflag,length(param.sensor)) %#ok<OR2>
                pauseflag(1:length(param.sensor)) = 0;
            end
            if ~pauseflag(i)
                if param.sensor(i).blflag<4
                    vane = findobj('tag',['vane',param.sensor(i).name]);
                    prop = findobj('tag',['propeller',param.sensor(i).name]);
                    current_idx = get(vane,'userdata');
                    next_idx = current_idx+1;
                    next_idx((next_idx>size(param.sensor(i).data{1},1))) = 1;
                    if ~ishandle(fighandle)
                        return;
                    end
                    rotate([vane,prop],[0 0 1],param.sensor(i).data{1}(current_idx,2)...
                        -param.sensor(i).data{1}(next_idx,2),[param.sensor(i).x,...
                        param.sensor(i).y,param.sensor(i).data{1}(1,1)]);
                    set(vane,'userdata',next_idx);
                    set(prop,'userdata',param.sensor(i).data{1}(next_idx,2))
                    pauseflag(i) = 1;
                else
                    balloon  = findobj('tag',['balloon',param.sensor(i).name]);
                    userdata = get(balloon,'userdata');
                    if ~ishandle(fighandle)
                        return;
                    end
                    next_idx    = userdata.idx+1;
                    next_idx((next_idx>length(userdata.z))) = 1;
                    z = get(balloon,'zdata') - userdata.z(userdata.idx);
                    z = z + userdata.z(next_idx);
                    userdata.idx = next_idx;
                    set(balloon,'zdata',z,'userdata',userdata);
                    if next_idx==1
                        pauseflag(i)=1;
                    end
                end
            end

        end
    end
    if ishandle(fighandle)
        if ~isequal(gcf,fighandle)
            setappdata(fighandle,'CurrentAnimationStatus',0);
        end
    end
end
if ishandle(fighandle)
    set(fighandle,'WindowButtonMotionFcn',{@city_motion_fcn,fighandle,param,domain,point_sensors,maxsensor_idx})
    % this updates the appdata that is used in cameratoolbar
    udata = getappdata(fighandle,'ctb200jaz');
    udata.wcb{2} = get(fighandle,'WindowButtonMotionFcn');
    setappdata(fighandle,'ctb200jaz',udata);
    setappdata(fighandle,'LastCameratoolbarMode',udata.mode);
    quicfigcameratoolbar('nomode')
end
