function MotionBasedMultiObjectTrackingExample()

% Create System objects used for reading video, detecting moving objects,
% and displaying the results.
obj = setupSystemObjects();

tracks = initializeTracks(); % Create an empty array of tracks.

nextId = 1; % ID of the next track

% Detect moving objects, and track them across video frames.
while ~isDone(obj.reader)
    frame = readFrame();
    [centroids, bboxes, mask] = detectObjects(frame);
    predictNewLocationsOfTracks();
    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();

    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();

    displayTrackingResults();
end

function obj = setupSystemObjects()
    % Initialize Video I/O
    % Create objects for reading a video from a file, drawing the tracked
    % objects in each frame, and playing the video.

    % Create a video file reader.
    obj.reader = vision.VideoFileReader('atrium.mp4');

    % Create two video players, one to display the video,
    % and one to display the foreground mask.
    obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);

    % Create System objects for foreground detection and blob analysis

    % The foreground detector is used to segment moving objects from
    % the background. It outputs a binary mask, where the pixel value
    % of 1 corresponds to the foreground and the value of 0 corresponds
    % to the background.

    obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
        'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

    % Connected groups of foreground pixels are likely to correspond to moving
    % objects.  The blob analysis System object is used to find such groups
    % (called 'blobs' or 'connected components'), and compute their
    % characteristics, such as area, centroid, and the bounding box.

    obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', 400);
end

function tracks = initializeTracks()
    % create an empty array of tracks
    tracks = struct(...
        'id', {}, ...
        'bbox', {}, ...
        'kalmanFilter', {}, ...
        'age', {}, ...
        'totalVisibleCount', {}, ...
        'consecutiveInvisibleCount', {});
end

function frame = readFrame()
    frame = obj.reader.step();
end

function [centroids, bboxes, mask] = detectObjects(frame)

    % Detect foreground.
    mask = obj.detector.step(frame);

    % Apply morphological operations to remove noise and fill in holes.
    mask = imopen(mask, strel('rectangle', [3,3]));
    mask = imclose(mask, strel('rectangle', [15, 15]));
    mask = imfill(mask, 'holes');

    % Perform blob analysis to find connected components.
    [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
end

function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % Shift the bounding box so that its center is at
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
    end
