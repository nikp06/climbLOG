classdef CTY_exe_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        TabGroup2                     matlab.ui.container.TabGroup
        ControlPanelTab               matlab.ui.container.Tab
        TabGroup                      matlab.ui.container.TabGroup
        SubjectDataTab                matlab.ui.container.Tab
        IDEditFieldLabel              matlab.ui.control.Label
        IDEditField                   matlab.ui.control.EditField
        SessionDropDownLabel          matlab.ui.control.Label
        SessionDropDown               matlab.ui.control.DropDown
        RouteDropDownLabel            matlab.ui.control.Label
        RouteDropDown                 matlab.ui.control.DropDown
        ArmReachcmEditFieldLabel      matlab.ui.control.Label
        ArmReachcmEditField           matlab.ui.control.NumericEditField
        ChangeButton_2                matlab.ui.control.Button
        FolderforOutputFilesLabel     matlab.ui.control.Label
        FolderforOutputFilesTextArea  matlab.ui.control.TextArea
        DefaultButton                 matlab.ui.control.Button
        TrialTab                      matlab.ui.container.Tab
        LButton                       matlab.ui.control.StateButton
        RButton                       matlab.ui.control.StateButton
        ChangeLastButton              matlab.ui.control.StateButton
        ReachableLampLabel            matlab.ui.control.Label
        ReachableLamp                 matlab.ui.control.Lamp
        GripValidLampLabel            matlab.ui.control.Label
        GripValidLamp                 matlab.ui.control.Lamp
        ChangeButton                  matlab.ui.control.StateButton
        LogButton                     matlab.ui.control.StateButton
        GripInfoTextAreaLabel         matlab.ui.control.Label
        InfoTextArea                  matlab.ui.control.TextArea
        Image                         matlab.ui.control.Image
        Table                         matlab.ui.container.Tab
        UITable                       matlab.ui.control.Table
        TrialinProgressLampLabel      matlab.ui.control.Label
        TrialinProgressLamp           matlab.ui.control.Lamp
        StartTrialSwitchLabel         matlab.ui.control.Label
        StartTrialSwitch              matlab.ui.control.ToggleSwitch
        LastTimestampTextAreaLabel    matlab.ui.control.Label
        LastTimestampTextArea         matlab.ui.control.TextArea
    end

    
    properties (Access = private)
        % Subject Variables
        ID = '' 
        % Time Variables
        TimeStart = 0
        LastTime = 0
        % Route Variables
        Holdnumbers = [145   146   147   148   149   150   151   152   153   154   155   156; 133   134   135   136   137   138   139   140   141   142   143   144; 121   122   123   124   125   126   127   128   129   130   131   132; 109   110   111   112   113   114   115   116   117   118   119   120; 97    98    99   100   101   102   103   104   105   106   107   108; 85    86    87    88    89    90    91    92    93    94    95    96; 73    74    75    76    77    78    79    80    81    82    83    84; 61    62    63    64    65    66    67    68    69    70    71    72; 49    50    51    52    53    54    55    56    57    58    59    60; 37    38    39    40    41    42    43    44    45    46    47    48; 25    26    27    28    29    30    31    32    33    34    35    36; 13    14    15    16    17    18    19    20    21    22    23    24; 1     2     3     4     5     6     7     8     9    10    11    12];
        GripImage = 0
        WaitRoute % = imread("routekommt.jpg")
        RouteName = "" % Description
        CurrentRoute = 0
        LastRoute = 0
        CurrentFigure = 0
        RouteRows = 0
        RouteColumns = 0
        SizeRows = 0
        SizeCols = 0
        % Monitor Variables
        MP = get(0, 'MonitorPositions')
        Shift = 0
        Position = 0
        % Stats Variables
        Completed = 0
        ArmReach = 0
        LastHand = 0
        LastGrip = [7 1]
        StartGrip = [7 1]
        BeforeGrip = [7 1]
        HorDis = 18
        VerDis = 19.5
        GripLog = []
        Distance = 0
        MeanDistance = 0
        % Table
        T = {};
        VarNames = ["ID", "Session", "Route", "Hold", "Completed", "Distance", "Arm Reach", "Time", "Mean Distance", "Hand"]
        % Folder Structure
        CurrentFolder
        DesktopPath
        CsvPath
        SessionPath % Description
        PrePost % Description
        FirstSecond % Description
        ThirdFourth % Description
        FifthSixth
        SeventhEigth
    end
    
    methods (Access = private)
        
        % Function for updating the time
        function updateTime(app, bool)
            if bool == 0
                app.TimeStart = tic;
                app.LastTimestampTextArea.Value = "0";
            else
                app.LastTime = toc(uint64(app.TimeStart));
                app.LastTimestampTextArea.Value = num2str(app.LastTime);
            end
        end
        
        % Function for opening a new route
        function openRoute(app, route)
            if app.CurrentFigure == 0 && app.Shift == 0
                app.CurrentFigure = figure("Visible", "Off");
                imshow(app.WaitRoute)
                hold on
            else
                app.CurrentRoute = imread(route);
                app.CurrentRoute = imresize(app.CurrentRoute,[app.SizeRows app.SizeCols]);
                if ~isvalid(app.CurrentFigure)
                    app.CurrentFigure = figure("Visible", "Off");
                    imshow(app.CurrentRoute)
                    hold on
                else
                    imshow(app.CurrentRoute)
                    return
                end
            end
            if size(app.MP, 1) == 2
                app.Shift = app.MP(2, 1:2);
                set(app.CurrentFigure, 'Units', 'pixels');
                pos = get(app.CurrentFigure, 'Position');
                app.Position = [pos(1:2) + app.Shift pos(3:4)];
                pause(0.02);  % See Stefan Glasauer's comment
                set(app.CurrentFigure, 'Position', [app.Position(1:2), app.Position(3:4)]);
                movegui(app.CurrentFigure,'center')
            end
            set(app.CurrentFigure, "Visible", "On")
        end
        
        % Function for checking the grip
        function [BW,maskedRGBImage] = createMask(~, RGB)
            %createMask  Threshold RGB image using auto-generated code from colorThresholder app.
            %  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
            %  auto-generated code from the colorThresholder app. The colorspace and
            %  range for each channel of the colorspace were set within the app. The
            %  segmentation mask is returned in BW, and a composite of the mask and
            %  original RGB images is returned in maskedRGBImage.
            
            % Auto-generated by colorThresholder app on 17-Feb-2021
            %------------------------------------------------------
            
            
            % Convert RGB image to chosen color space
            I = rgb2hsv(RGB);
            
            % Define thresholds for channel 1 based on histogram settings
            channel1Min = 0.445;
            channel1Max = 0.213;
            
            % Define thresholds for channel 2 based on histogram settings
            channel2Min = 0.413;
            channel2Max = 1.000;
            
            % Define thresholds for channel 3 based on histogram settings
            channel3Min = 0.000;
            channel3Max = 1.000;
            
            % Create mask based on chosen histogram thresholds
            sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
                (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
            BW = sliderBW;
            
            % Initialize output masked image based on input image.
            maskedRGBImage = RGB;
            
            % Set background pixels where BW is false to zero.
            maskedRGBImage(repmat(~BW,[1 1 3])) = 0;
            
        end
        
        function [a_idxs, b_idxs, grip, pxl_idxs] = getInput(app, bool)
            if bool == 1
                [column, row] = ginput(1);
            % getting baseline from grip in upper right corner
            elseif bool == 2
                column = app.RouteColumns - 1;
                row = 1;
            % getting baseline from grip in lower left corner
            else
                column = 1;
                row = app.RouteRows - 1;
            end
            try
                cols = linspace(1,app.RouteColumns,13);
                rows = linspace(app.RouteRows,1,14);
                
                % checking for col
                values = abs(cols-column);
                [~, a_order] = sort(values);
                a_idxs = sort(a_order(1:2));
                
                % checking for row
                values = abs(rows-row);
                [~, b_order] = sort(values);
                b_idxs = sort(b_order(1:2));
                
                pxl_idxs = [sort([round(cols(a_idxs(1))) round(cols(a_idxs(2)))]), sort([round(rows(b_idxs(1))) round(rows(b_idxs(2)))])];
    
                grip = app.CurrentRoute(pxl_idxs(3):pxl_idxs(4),pxl_idxs(1):pxl_idxs(2),:);
                gripCoords = [a_idxs(1) b_idxs(1)];
                if app.gripUsed(gripCoords) == 1
                    throw(exception)
                    % error("grip used")
                end
            catch
%                 throw(exception)
                return
            end
        end
        
        function grip = greenifyGrip(~, grip, color)
            I = grip;
            if color == "red"
                I(:,:,1:2) = circshift(I(:,:,1:2),1,3);
            elseif color == "blue"
                I(:,:,2:3) = circshift(I(:,:,2:3),1,3);
            end
            grip = I;
        end
        
        function endRoute(app)
            app.TrialinProgressLamp.Color = [1 0 0];
            app.TabGroup.SelectedTab = app.SubjectDataTab;
            app.updateTime(1)
            imshow(app.WaitRoute)
            app.ReachableLamp.Color = [1 1 0];
            %% safe everything to table
            %% initiate all variable to start again
            app.LastHand = 0;
            app.LastGrip = [7 1];
            app.StartGrip = [7 1];
            app.BeforeGrip = [7 1];
            app.GripLog = [];
            app.LastTime = 0;
            app.MeanDistance = 0;
        end
        
        function startTrial(app)
            threshold = app.defineThreshold();
            counter = 0;
            %% GET INPUT
            % loop and get input from subject until last red grip is
            % reached (enforce blue and red grips)
            while 1 %griff ~= "letzter rot"
                while 1
                    % getting input
                    try
                        [a_idxs, b_idxs, grip, pxl_idxs] = getInput(app, 1);
                        gripCoords = [a_idxs(1) b_idxs(1)];
                    catch
                        return
                    end
                    if gripUsed(app, gripCoords) == 1
                        continue
                    end
                    %% check if grip is blue (valid) or red (finished route) or something else (not valid)
                    [BW, ~] = app.createMask(grip);
                    sum(BW, 'all')
                    if counter == 0
                        % first grip is start grip
                        if isequal(a_idxs(1:2), [7 8]) && isequal(b_idxs(1:2), [1 2])
                            color = "red";
                            break
                        else
                            % enforce first grip to be start grip
                            continue;
                        end
                    elseif sum(BW, 'all') > threshold
                        color = "blue";
                        break
                    end
                end
                if isequal(b_idxs(1:2), [13 14]) && (sum(BW, 'all') > threshold)
                    color = "red";
                end
                %% MAKE GRIP GREEN
                % change color of the grip
                grip = greenifyGrip(app, grip, color);
                app.LastRoute = app.CurrentRoute;
                app.CurrentRoute(pxl_idxs(3):pxl_idxs(4),pxl_idxs(1):pxl_idxs(2),:) = grip;
                imshow(app.CurrentRoute)
                app.Image.ImageSource = app.CurrentRoute;

                % START GRIP (no need to ask for hand) and also second grip
                % is with both handsapp.LastHand
%                 if isequal(app.StartGrip, gripCoords)
                if isempty(app.GripLog) || size(app.GripLog,1) == 1 || contains(app.RouteDropDown.Value, "same")
                    hand = 3;
                else
                    hand = app.askHand();
                end
                if hand == 0
                    continue
                elseif hand == 1 || hand == 2 || hand == 3% left or right
                    %% CHECKINPUT (CHECK WHETHER INPUT IS IN LINE WITH ARM REACH AND WHAT ROUTE IS DEMANDING!
                    [valid, ~] = app.checkInput(hand, gripCoords);
                    % valid == 0 means grip was against some rule (more
                    % right/left/always higher)
                    if valid == 0
                        app.CurrentRoute = app.LastRoute;
                        imshow(app.LastRoute)
                        app.Image.ImageSource = app.LastRoute;
                        app.ReachableLamp.Color = [1 1 0];
                        continue
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%% !!!! LOG EVERYTHING !!!! %%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    app.InfoTextArea.Value = "Logged - waiting for new Input";
%                     newData = {app.ID app.SessionDropDown.Value app.RouteDropDown.Value}; %sample data for each column
%                     app.UITable.Data = [{app.UITable.Data(:)};newData];
                    app.MeanDistance = app.MeanDistance + app.Distance;
                    newData = {app.ID, string(app.SessionDropDown.Value), app.RouteDropDown.Value, app.Holdnumbers(end+1-app.LastGrip(2),app.LastGrip(1)), app.Completed, round(app.Distance, 2), app.ArmReachcmEditField.Value, round(app.LastTime, 2),date, 0, app.LastHand};
                    if isempty(app.T)
                        app.T = newData;
                    else
                        app.T(end+1,:) = newData;
                    end
                    
                    app.T
                    
                    % END GRIP (END ROUTE IF GRIP IS VALID)
                    if color == "red" && counter ~= 0
                        app.StartTrialSwitch.Value = "Off";
                        app.T(end-counter:end, 10) = {round(app.MeanDistance/(counter), 2)};
                        app.endRoute()
                        table = cell2table(app.T);
                        app.UITable.Data = table;
                        break
                    end
                end
                app.updateTime(1)
                counter = counter + 1;
            end
        end
        
        function state = askHand(app)
            state = 0;
            app.LButton.Enable = "On";
            app.RButton.Enable = "On";
            app.ChangeLastButton.Enable = "On";
            
            app.MyKeyPressListener(1)
            while (app.LButton.Value ~=1) && (app.RButton.Value ~=1) && (app.ChangeLastButton.Value ~=1)
                pause(0.5);
            end
            app.MyKeyPressListener(0)
            
            if app.ChangeLastButton.Value == 1
                app.CurrentRoute = app.LastRoute;
                imshow(app.CurrentRoute)
                app.Image.ImageSource = app.CurrentRoute;
            elseif app.LButton.Value == 1
                state = 1;
            else
                state = 2;
            end
            app.LButton.Value = 0;
            app.RButton.Value = 0;
            app.ChangeLastButton.Value = 0;
            app.LButton.Enable = "Off";
            app.RButton.Enable = "Off";
            app.ChangeLastButton.Enable = "Off";
        end
        
        function [valid, reachable] = checkInput(app, hand, gripCoords)
            valid = 1;
            reachable = 1;
            %% DISTANCE WHEN GRIPS WITH SAME HANDS
            if hand == app.LastHand && app.LastHand ~= 3
                distance = sqrt((app.HorDis*(gripCoords(1) - app.BeforeGrip(1)))^2 + (app.VerDis*(gripCoords(2) - app.BeforeGrip(2)))^2);
                if ~isequal(gripCoords, [7 1]) && ~isequal(app.LastGrip, [7 1]) && gripCoords(2) ~= 13
                    %% CHECK THAT GRIP IS ALWAYS HIGHER THAN LAST
                    if gripCoords(2) < app.LastGrip(2)
                        app.InfoTextArea.Value = "Grip below last grip of same hand - waiting for new input ...";
                        valid = 0;
                    %% CHECK THAT GRIP IS ALWAYS MORE RIGHT IF ROUTE IS MORE RIGHT
                    elseif gripCoords(1) < app.LastGrip(1) && contains(app.RouteDropDown.Value, "moreright")
                        app.InfoTextArea.Value = "Grip not more right to last grip of same hand - waiting for new input ...";
                        valid = 0;
                    %% CHECK THAT GRIP IS ALWAYS MORE LEFT IF ROUTE IS MORE LEFT
                    elseif gripCoords(1) > app.LastGrip(1) && contains(app.RouteDropDown.Value, "moreleft")
                        app.InfoTextArea.Value = "Grip not more left to last grip of same hand - waiting for new input ...";
                        valid = 0;
                    end
                end
            %% NORMAL DISTANCE GRIP TO LASTGRIP
            else
                distance = sqrt((app.HorDis*(gripCoords(1) - app.LastGrip(1)))^2 + (app.VerDis*(gripCoords(2) - app.LastGrip(2)))^2);
                if ~isequal(gripCoords, [7 1]) && ~isequal(app.BeforeGrip, [7 1]) && gripCoords(2) ~= 13
                    %% CHECK THAT GRIP IS ALWAYS HIGHER THAN LAST
                    if gripCoords(2) < app.BeforeGrip(2)
                        app.InfoTextArea.Value = "Grip below last grip of same hand - waiting for new input ...";
                        valid = 0;
                    %% CHECK THAT GRIP IS ALWAYS MORE RIGHT IF ROUTE IS MORE RIGHT
                    elseif gripCoords(1) < app.BeforeGrip(1) && contains(app.RouteDropDown.Value, "moreright")
                        app.InfoTextArea.Value = "Grip not more right to last grip of same hand - waiting for new input ...";
                        valid = 0;
                    %% CHECK THAT GRIP IS ALWAYS MORE LEFT IF ROUTE IS MORE LEFT
                    elseif gripCoords(1) > app.BeforeGrip(1) && contains(app.RouteDropDown.Value, "moreleft")
                        app.InfoTextArea.Value = "Grip not more left to last grip of same hand - waiting for new input ...";
                        valid = 0;
                    end
                end
            end
            
            %% CHECK THAT GRIP IS ALWAYS HIGHER (NO MATTER WHAT HAND) IN PRE/POST
            if contains(app.SessionDropDown.Value, "Pre") || contains(app.SessionDropDown.Value, "Post")
                if gripCoords(2) < app.LastGrip(2)
                    app.InfoTextArea.Value = "In pre/post grip must always be higher than last - waiting for new input ...";
                    valid = 0;
                end
            end
            app.GripLog
            %% CHECK IF SECOND GRIP IS ALWAYS IN 2ND OR 3RD ROW (don't know which row exactly)
            if size(app.GripLog,1) == 1
                if isequal(app.SessionDropDown.Value, "Pre") || isequal(app.SessionDropDown.Value, "Post")
                    if gripCoords(2) ~= 3
                        app.InfoTextArea.Value = "Second Grip must always be in 3rd row (pre/post) - waiting for new input ...";
                        valid = 0;
                    end
                elseif ~isequal(app.SessionDropDown.Value, "Pre") && ~isequal(app.SessionDropDown.Value, "Post")
                    if gripCoords(2) ~= 2
                        app.InfoTextArea.Value = "Second Grip must always be in 2nd row ~(pre/post) - waiting for new input ...";
                        valid = 0;
                    end
                end
            end
            
            if valid == 0
                % if valid == 0 due to other reason dont change grip
                app.GripValidLamp.Color = [1 0 0];
                return
            end
            
            %% distance check (for 50% of arm reach) and if not first grip after start
            if distance > app.ArmReach * 0.5 && size(app.GripLog,1) ~= 1
                reachable = 0;
                app.ReachableLamp.Color = [1 0 0];
                app.Completed = 0;
                %% if pre or post subject should not be able to change grip
                if app.SessionDropDown.Value == "Pre" || app.SessionDropDown.Value == "Post"
                    valid = 1;
                %% if not -> offer to change (valid == 2 means poss to change)
                else
                    app.ReachableLamp.Color = [1 0 0];
                    app.GripValidLamp.Color = [1 1 0];
                    valid = 2;
                    app.InfoTextArea.Value = "Too far - change or log?";
                    app.ChangeButton.Enable = "On";
                    app.LogButton.Enable = "On";
                    app.MyKeyPressListener(1)
                    while (app.ChangeButton.Value ~=1) && (app.LogButton.Value ~=1)
                        pause(0.5);
                    end
                    app.MyKeyPressListener(0)
                    if app.ChangeButton.Value == 1
                        app.CurrentRoute = app.LastRoute;
                        imshow(app.LastRoute)
                        app.Image.ImageSource = app.LastRoute;
                        app.ChangeButton.Value = 0;
                        app.ChangeButton.Enable = "Off";
                        app.LogButton.Enable = "Off";
                        app.GripValidLamp.Color = [1 1 0];
                        app.ReachableLamp.Color = [1 1 0];
                        app.InfoTextArea.Value = "Not Logged - waiting for input ...";
                        return
                    else
                        app.LogButton.Value = 0;
                        app.ChangeButton.Enable = "Off";
                        app.LogButton.Enable = "Off";
                        app.InfoTextArea.Value = "Logged - waiting for input ...";
                    end
                end
            else
                app.Completed = 1;
                app.ReachableLamp.Color = [0 1 0];
            end

            if valid == 1
                app.GripValidLamp.Color = [0 1 0];
            end
            
            %% IF PROGRAM REACHES HERE ALL IS VALID AND GRIPS ARE UPDATED TO NEW GRIPS
            app.Distance = distance;
            if hand ~= app.LastHand && hand ~= 3
                app.BeforeGrip = app.LastGrip;
            end
            app.LastHand = hand;
            app.LastGrip = [gripCoords(1) gripCoords(2)];
            if isempty(app.GripLog)
                app.GripLog = gripCoords;
            else
                app.GripLog = [app.GripLog; gripCoords];
            end
        end
        
        function bool = gripUsed(app, gripCoords)
            bool = 0;
            if ~isempty(app.GripLog)
                for i=1:length(app.GripLog(:,1))
                    if app.GripLog(i,:) == gripCoords
                        bool = 1;
                    end
                end
            end
        end
        
        
        function MyKeyPressListener(app, bool)
            hFig = app.CurrentFigure;
            if bool == 1
                set(hFig,'WindowKeyPressFcn',@keyPressCallback);
            else
                set(hFig,'WindowKeyPressFcn',@none);
            end
            function keyPressCallback(~,eventdata)
%                 determine the key that was pressed
                keyPressed = eventdata.Key;
                if isequal(app.LButton.Enable, "on")
                    if strcmpi(keyPressed,'rightarrow')
                        app.RButton.Value = 1;
                    elseif strcmpi(keyPressed,'leftarrow')
                        app.LButton.Value = 1;
                    elseif strcmpi(keyPressed,'c')
                        app.ChangeLastButton.Value = 1;
                    end
                elseif isequal(app.LogButton.Enable, "on")
                    if strcmpi(keyPressed,'rightarrow')
                        app.LogButton.Value = 1;
                    elseif strcmpi(keyPressed,'leftarrow')
                        app.ChangeButton.Value = 1;
                    end
                end
            end
            function none()
                return
            end
        end
        
        function threshold = defineThreshold(app)
            % getting baseline from grip in upper right corner
            [~, ~, grip1, ~] = getInput(app, 2);
            % getting baseline from grip in lower left corner
            [~, ~, grip2, ~] = getInput(app, 3);
            [BW1, ~] = app.createMask(grip1);
            [BW2, ~] = app.createMask(grip2);
            threshold = (sum(BW1, 'all') + sum(BW2, 'all')) / 2 + 60;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Get the type of SpecialFolder enum, this is a nested enum type.
            specialFolderType = System.Type.GetType(...
                'System.Environment+SpecialFolder');
            % Get a list of all SpecialFolder enum values 
            folders = System.Enum.GetValues(specialFolderType);
            enumArg = [];
             
            % Find the matching enum value requested by the user
            for i = 1:folders.Length
                if (strcmp(char(folders(i)), 'Desktop'))
                    enumArg = folders(i);
                break
                end
            end
             
            % Validate
            if(isempty(enumArg))
                error('Invalid Argument')
            end
             
            % Call GetFolderPath method and return the result
            app.DesktopPath = string(System.Environment.GetFolderPath(enumArg));
            app.CsvPath = fullfile(app.DesktopPath, 'CTY_SubjectTables');
            app.FolderforOutputFilesTextArea.Value = app.CsvPath;
            %% everything that needs to be loaded when starting app goes here
            
            if ~isdeployed
                app.CurrentFolder = pwd;
            else
                app.CurrentFolder = fullfile(ctfroot, 'CTY');
            end
            
            app.WaitRoute = imread(fullfile(app.CurrentFolder, "routekommt.jpg"));
            app.openRoute(app.WaitRoute);
            [app.SizeRows, app.SizeCols, ~] = size(app.WaitRoute);
            
            app.PrePost = dir(fullfile(app.CurrentFolder, 'Cog_Routes', 'Pre_Post', '*.jpg'));
            app.FirstSecond = dir(fullfile(app.CurrentFolder, 'Cog_Routes', '1_2', '*.jpg'));
            app.ThirdFourth = dir(fullfile(app.CurrentFolder, 'Cog_Routes', '3_4', '*.jpg'));
            app.FifthSixth = dir(fullfile(app.CurrentFolder, 'Cog_Routes', '5_6', '*.jpg'));
            app.SeventhEigth = dir(fullfile(app.CurrentFolder, 'Cog_Routes', '7_8', '*.jpg'));
%             app.FirstSecond = dir([app.CurrentFolder '\Cog_Routes\1_2\*.jpg']);
%             app.ThirdFourth = dir([app.CurrentFolder '\Cog_Routes\3_4\*.jpg']);
%             app.FifthSixth = dir([app.CurrentFolder '\Cog_Routes\5_6\*.jpg']);
%             app.SeventhEigth = dir([app.CurrentFolder '\Cog_Routes\7_8\*.jpg']);
        end

        % Value changed function: SessionDropDown
        function SessionDropDownValueChanged(app, event)
            value = app.SessionDropDown.Value;
            % if value is still on default route cannot be chosen
            if value == "Select"
                app.RouteDropDown.Enable = "Off";
                app.StartTrialSwitch.Enable = "Off";
                return
            end
            
            % specify which routes are availbale for which session
            if value == "Pre" || value == "Post"
                app.SessionPath = fullfile(app.CurrentFolder, 'Cog_Routes', 'Pre_Post'); %[app.CurrentFolder '\Cog_Routes\Pre_Post\'];
                filenames = {app.PrePost.name};
                app.RouteDropDown.Items = [{'Select Route'} filenames];
            elseif value == "1" || value == "2"
                app.SessionPath = fullfile(app.CurrentFolder, 'Cog_Routes', '1_2');
                filenames = {app.FirstSecond.name};
            elseif value == "3" || value == "4"
                app.SessionPath = fullfile(app.CurrentFolder, 'Cog_Routes', '3_4');
                filenames = {app.ThirdFourth.name};
            elseif value == "5" || value == "6"
                app.SessionPath = fullfile(app.CurrentFolder, 'Cog_Routes', '5_6');
                filenames = {app.FifthSixth.name};
            elseif value == "7" || value == "8"
                app.SessionPath = fullfile(app.CurrentFolder, 'Cog_Routes', '7_8');
                filenames = {app.SeventhEigth.name};
            end
            app.RouteDropDown.Items = [{'Select Route'} filenames];
            app.RouteDropDown.Enable = "On";
        end

        % Value changing function: IDEditField
        function IDEditFieldValueChanging(app, event)
            changingValue = event.Value;
            if isempty(changingValue) || isempty(app.ArmReachcmEditField.Value)
                app.SessionDropDown.Enable = "Off";
                app.RouteDropDown.Enable = "Off";
                app.StartTrialSwitch.Enable = "Off";
                return
            end
            app.SessionDropDown.Enable = "On";
        end

        % Value changed function: IDEditField
        function IDEditFieldValueChanged(app, event)
            value = app.IDEditField.Value;
            
            if ~isfolder(app.CsvPath)
                mkdir(app.CsvPath)
            end
            
            if ~isempty(app.T)
                if isfolder(app.CsvPath)
                % if isfile([app.ID '.csv'])
                    if isfile(fullfile(app.CsvPath, [app.ID '.csv']))
                        old = table2cell(readtable(fullfile(app.CsvPath, [app.ID '.csv'])));
                        new = [old; app.T];
                        t = cell2table(new,"VariableNames",{'ID', 'Session', 'Route', 'Hold', 'Completed', 'Distance', 'Arm Reach', 'Time', 'Date', 'Mean Distance', 'Hand'}); 
                    else
                        t = cell2table(app.T,"VariableNames",{'ID', 'Session', 'Route', 'Hold', 'Completed', 'Distance', 'Arm Reach', 'Time', 'Date', 'Mean Distance', 'Hand'});
                    end
                    writetable(t, fullfile(app.CsvPath, [app.ID '.csv']));
                    app.T = {};
                end
            end
            app.ID = value;
            fclose('all');
        end

        % Value changed function: RouteDropDown
        function RouteDropDownValueChanged(app, event)
            value = app.RouteDropDown.Value;
            if value == "Select Route"
                return
            end
            app.RouteName = fullfile(app.SessionPath, value); %[app.SessionPath value];
            app.Image.ImageSource = app.RouteName;
            app.StartTrialSwitch.Enable = "On";
        end

        % Value changed function: StartTrialSwitch
        function StartTrialSwitchValueChanged(app, event)
            value = app.StartTrialSwitch.Value;
            
            if value == "On"
                app.TrialinProgressLamp.Color = [0 1 0];
                app.TabGroup.SelectedTab = app.TrialTab;
                app.LastTimestampTextArea.Visible = "On";
                app.LastTimestampTextAreaLabel.Visible = "On";
                app.updateTime(0)
                
                % Open up Figure for Subject
                app.openRoute(app.RouteName);
                
                [app.RouteRows, app.RouteColumns, ~] = size(app.CurrentRoute);
                
                % get matrix or table from this
                app.startTrial();
                
            else
                app.endRoute();
                close(app.CurrentFigure)
            end
        end

        % Value changed function: ArmReachcmEditField
        function ArmReachcmEditFieldValueChanged(app, event)
            value = app.ArmReachcmEditField.Value;
            if isempty(value) || isempty(app.IDEditField.Value)
                app.SessionDropDown.Enable = "Off";
                app.RouteDropDown.Enable = "Off";
                app.StartTrialSwitch.Enable = "Off";
                return
            end
            
            app.ArmReach = value;
            
            app.SessionDropDown.Enable = "On";
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            if ~isfolder(app.CsvPath)
                mkdir(app.CsvPath)
            end

            try
                if ~isempty(app.T)
                    if isfile(fullfile(app.CsvPath, [app.ID '.csv']))
                        old = table2cell(readtable(fullfile(app.CsvPath, [app.ID '.csv'])));
                        new = [old; app.T];
                        t = cell2table(new,"VariableNames",{'ID', 'Session', 'Route', 'Hold', 'Completed', 'Distance', 'Arm Reach', 'Time', 'Date', 'Mean Distance', 'Hand'}); 
                    else
                        t = cell2table(app.T,"VariableNames",{'ID', 'Session', 'Route', 'Hold', 'Completed', 'Distance', 'Arm Reach', 'Time', 'Date', 'Mean Distance', 'Hand'});
                    end
                    writetable(t, fullfile(app.CsvPath, [app.ID '.csv']));
                    app.T = {};
                end
            catch
            end

            
            delete(app)
            fclose('all');
            close all;
        end

        % Button pushed function: ChangeButton_2
        function ChangeButton_2Pushed(app, event)
            app.CsvPath = string(uigetdir(app.DesktopPath, 'Select Folder where CSV-files are saved'));
            app.FolderforOutputFilesTextArea.Value = app.CsvPath;
        end

        % Button pushed function: DefaultButton
        function DefaultButtonPushed(app, event)
            app.CsvPath = fullfile(app.DesktopPath, 'CTY_SubjectTables');
            app.FolderforOutputFilesTextArea.Value = app.CsvPath;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 852 548];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.UIFigure);
            app.TabGroup2.Position = [26 15 801 482];

            % Create ControlPanelTab
            app.ControlPanelTab = uitab(app.TabGroup2);
            app.ControlPanelTab.Title = 'Control Panel';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ControlPanelTab);
            app.TabGroup.Position = [504 29 260 400];

            % Create SubjectDataTab
            app.SubjectDataTab = uitab(app.TabGroup);
            app.SubjectDataTab.Title = 'Subject Data';

            % Create IDEditFieldLabel
            app.IDEditFieldLabel = uilabel(app.SubjectDataTab);
            app.IDEditFieldLabel.HorizontalAlignment = 'right';
            app.IDEditFieldLabel.Position = [76 334 25 22];
            app.IDEditFieldLabel.Text = 'ID';

            % Create IDEditField
            app.IDEditField = uieditfield(app.SubjectDataTab, 'text');
            app.IDEditField.ValueChangedFcn = createCallbackFcn(app, @IDEditFieldValueChanged, true);
            app.IDEditField.ValueChangingFcn = createCallbackFcn(app, @IDEditFieldValueChanging, true);
            app.IDEditField.Position = [116 334 100 22];

            % Create SessionDropDownLabel
            app.SessionDropDownLabel = uilabel(app.SubjectDataTab);
            app.SessionDropDownLabel.HorizontalAlignment = 'right';
            app.SessionDropDownLabel.Position = [53 247 48 22];
            app.SessionDropDownLabel.Text = 'Session';

            % Create SessionDropDown
            app.SessionDropDown = uidropdown(app.SubjectDataTab);
            app.SessionDropDown.Items = {'Select', 'Pre', '1', '2', '3', '4', '5', '6', '7', '8', 'Post'};
            app.SessionDropDown.ValueChangedFcn = createCallbackFcn(app, @SessionDropDownValueChanged, true);
            app.SessionDropDown.Enable = 'off';
            app.SessionDropDown.Position = [116 247 100 22];
            app.SessionDropDown.Value = 'Select';

            % Create RouteDropDownLabel
            app.RouteDropDownLabel = uilabel(app.SubjectDataTab);
            app.RouteDropDownLabel.HorizontalAlignment = 'right';
            app.RouteDropDownLabel.Position = [63 211 38 22];
            app.RouteDropDownLabel.Text = 'Route';

            % Create RouteDropDown
            app.RouteDropDown = uidropdown(app.SubjectDataTab);
            app.RouteDropDown.Items = {'Select Route'};
            app.RouteDropDown.ValueChangedFcn = createCallbackFcn(app, @RouteDropDownValueChanged, true);
            app.RouteDropDown.Enable = 'off';
            app.RouteDropDown.Position = [116 211 100 22];
            app.RouteDropDown.Value = 'Select Route';

            % Create ArmReachcmEditFieldLabel
            app.ArmReachcmEditFieldLabel = uilabel(app.SubjectDataTab);
            app.ArmReachcmEditFieldLabel.HorizontalAlignment = 'right';
            app.ArmReachcmEditFieldLabel.Position = [8 297 93 22];
            app.ArmReachcmEditFieldLabel.Text = 'Arm Reach (cm)';

            % Create ArmReachcmEditField
            app.ArmReachcmEditField = uieditfield(app.SubjectDataTab, 'numeric');
            app.ArmReachcmEditField.Limits = [1 Inf];
            app.ArmReachcmEditField.ValueChangedFcn = createCallbackFcn(app, @ArmReachcmEditFieldValueChanged, true);
            app.ArmReachcmEditField.Position = [116 297 100 22];
            app.ArmReachcmEditField.Value = 1;

            % Create ChangeButton_2
            app.ChangeButton_2 = uibutton(app.SubjectDataTab, 'push');
            app.ChangeButton_2.ButtonPushedFcn = createCallbackFcn(app, @ChangeButton_2Pushed, true);
            app.ChangeButton_2.Tooltip = {'Change Output Folder where Csv-Files are saved'};
            app.ChangeButton_2.Position = [143 42 52 24];
            app.ChangeButton_2.Text = 'Change';

            % Create FolderforOutputFilesLabel
            app.FolderforOutputFilesLabel = uilabel(app.SubjectDataTab);
            app.FolderforOutputFilesLabel.Position = [8 43 130 22];
            app.FolderforOutputFilesLabel.Text = 'Folder for Output Files:';

            % Create FolderforOutputFilesTextArea
            app.FolderforOutputFilesTextArea = uitextarea(app.SubjectDataTab);
            app.FolderforOutputFilesTextArea.Position = [8 18 243 22];

            % Create DefaultButton
            app.DefaultButton = uibutton(app.SubjectDataTab, 'push');
            app.DefaultButton.ButtonPushedFcn = createCallbackFcn(app, @DefaultButtonPushed, true);
            app.DefaultButton.Position = [201 42 49 24];
            app.DefaultButton.Text = 'Default';

            % Create TrialTab
            app.TrialTab = uitab(app.TabGroup);
            app.TrialTab.Title = 'Trial';

            % Create LButton
            app.LButton = uibutton(app.TrialTab, 'state');
            app.LButton.Enable = 'off';
            app.LButton.Text = 'L';
            app.LButton.Position = [18 266 100 71];

            % Create RButton
            app.RButton = uibutton(app.TrialTab, 'state');
            app.RButton.Enable = 'off';
            app.RButton.Text = 'R';
            app.RButton.Position = [143 266 100 71];

            % Create ChangeLastButton
            app.ChangeLastButton = uibutton(app.TrialTab, 'state');
            app.ChangeLastButton.Enable = 'off';
            app.ChangeLastButton.Text = 'Change Last';
            app.ChangeLastButton.Position = [80 231 100 22];

            % Create ReachableLampLabel
            app.ReachableLampLabel = uilabel(app.TrialTab);
            app.ReachableLampLabel.HorizontalAlignment = 'right';
            app.ReachableLampLabel.Position = [20 189 63 22];
            app.ReachableLampLabel.Text = 'Reachable';

            % Create ReachableLamp
            app.ReachableLamp = uilamp(app.TrialTab);
            app.ReachableLamp.Position = [98 189 20 20];
            app.ReachableLamp.Color = [1 1 0];

            % Create GripValidLampLabel
            app.GripValidLampLabel = uilabel(app.TrialTab);
            app.GripValidLampLabel.HorizontalAlignment = 'right';
            app.GripValidLampLabel.Position = [143 188 57 22];
            app.GripValidLampLabel.Text = 'Grip Valid';

            % Create GripValidLamp
            app.GripValidLamp = uilamp(app.TrialTab);
            app.GripValidLamp.Position = [215 188 20 20];
            app.GripValidLamp.Color = [1 1 0];

            % Create ChangeButton
            app.ChangeButton = uibutton(app.TrialTab, 'state');
            app.ChangeButton.Enable = 'off';
            app.ChangeButton.Text = 'Change';
            app.ChangeButton.Position = [19 29 100 81];

            % Create LogButton
            app.LogButton = uibutton(app.TrialTab, 'state');
            app.LogButton.Enable = 'off';
            app.LogButton.Text = 'Log';
            app.LogButton.Position = [143 29 100 81];

            % Create GripInfoTextAreaLabel
            app.GripInfoTextAreaLabel = uilabel(app.TrialTab);
            app.GripInfoTextAreaLabel.HorizontalAlignment = 'right';
            app.GripInfoTextAreaLabel.Position = [19 138 52 22];
            app.GripInfoTextAreaLabel.Text = 'Grip Info';

            % Create InfoTextArea
            app.InfoTextArea = uitextarea(app.TrialTab);
            app.InfoTextArea.Position = [86 121 150 56];

            % Create Image
            app.Image = uiimage(app.ControlPanelTab);
            app.Image.Position = [35 30 398 400];
            app.Image.ImageSource = 'wall_select1.jpg';

            % Create Table
            app.Table = uitab(app.TabGroup2);
            app.Table.Title = 'Table';

            % Create UITable
            app.UITable = uitable(app.Table);
            app.UITable.ColumnName = {'ID'; 'Session'; 'Route'; 'Hold'; 'Completed'; 'Distance'; 'Arm Reach'; 'Elapsed Time'; 'Date'; 'Mean Distance'; 'Same Hand'};
            app.UITable.RowName = {};
            app.UITable.Position = [2 1 798 456];

            % Create TrialinProgressLampLabel
            app.TrialinProgressLampLabel = uilabel(app.UIFigure);
            app.TrialinProgressLampLabel.HorizontalAlignment = 'right';
            app.TrialinProgressLampLabel.Position = [467 512 92 22];
            app.TrialinProgressLampLabel.Text = 'Trial in Progress';

            % Create TrialinProgressLamp
            app.TrialinProgressLamp = uilamp(app.UIFigure);
            app.TrialinProgressLamp.Position = [574 512 20 20];
            app.TrialinProgressLamp.Color = [1 0 0];

            % Create StartTrialSwitchLabel
            app.StartTrialSwitchLabel = uilabel(app.UIFigure);
            app.StartTrialSwitchLabel.HorizontalAlignment = 'center';
            app.StartTrialSwitchLabel.Position = [279 512 57 22];
            app.StartTrialSwitchLabel.Text = 'Start Trial';

            % Create StartTrialSwitch
            app.StartTrialSwitch = uiswitch(app.UIFigure, 'toggle');
            app.StartTrialSwitch.Orientation = 'horizontal';
            app.StartTrialSwitch.ValueChangedFcn = createCallbackFcn(app, @StartTrialSwitchValueChanged, true);
            app.StartTrialSwitch.Enable = 'off';
            app.StartTrialSwitch.Position = [372 514 45 20];

            % Create LastTimestampTextAreaLabel
            app.LastTimestampTextAreaLabel = uilabel(app.UIFigure);
            app.LastTimestampTextAreaLabel.HorizontalAlignment = 'right';
            app.LastTimestampTextAreaLabel.Visible = 'off';
            app.LastTimestampTextAreaLabel.Position = [630 512 90 22];
            app.LastTimestampTextAreaLabel.Text = 'Last Timestamp';

            % Create LastTimestampTextArea
            app.LastTimestampTextArea = uitextarea(app.UIFigure);
            app.LastTimestampTextArea.HorizontalAlignment = 'center';
            app.LastTimestampTextArea.Visible = 'off';
            app.LastTimestampTextArea.Position = [735 513 80 21];
            app.LastTimestampTextArea.Value = {'0'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CTY_exe_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end