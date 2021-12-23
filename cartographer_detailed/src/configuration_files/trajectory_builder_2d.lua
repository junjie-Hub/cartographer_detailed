-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

TRAJECTORY_BUILDER_2D = {

  --Whether to use imu data
  use_imu_data = true,            

  --The farthest and nearest filtering of radar data, save the intermediate value
  min_range = 0.,                 
  max_range = 30.,

  -- Set the filtering of radar data on the z-axis to convert 3d data into 2d
  min_z = -0.8,                   -- The highest and lowest filtering of radar data, save the intermediate value
  max_z = 2.,

  --Data points that exceed the maximum distance range 
  --are replaced by this distance for processing the miss collection
  missing_data_ray_length = 5.,   

  --Whenever the number of accumulated sensor data exceeds this value, Cartographer executes the front-end part. 
  --Phenomenally, this is related to reducing the distortion of radar data caused by motion.
  --Cartographer accumulates num_accumulated_range_data frames into one large frame as the input of the algorithm.
  --Cartographer believes that each frame is independent. It compensates for the distortion of the lidar data 
  --caused by motion in units of frames, and then gathers these frames together.
  --Therefore, the higher the frequency of the data frame received by Cartographer, the better the compensation
  -- effect of Cartographer and the higher the quality of the input data of the algorithm.
  --When I set it to 10, the scan update of the radar is very slow and cannot keep up with the movement of the robot, 
  --so it is generally set to 1 for 2D radar.
  num_accumulated_range_data = 1, -- Several frames of valid point cloud data are scanned and matched once

  --Surfaces closer to the radar (such as roads) often get more sampling points, while the sampling points
  -- for distant objects are relatively rare.
  --In order to reduce the amount of calculation, it is necessary to down-sample the point cloud data. Simple random 
  --sampling will still result in fewer points in the low-density area, and more points in the high-density area.
  --Therefore, cartographer uses the voxel_filter (voxel filter) method.
  --The side length of the voxel filtered cube
  voxel_filter_size = 0.025,     

  
  -- Voxel filters are used to generate sparse point clouds for scan matching
  adaptive_voxel_filter = {
    max_length = 0.5,             -- Try to determine the best cube side length, the maximum side length is 0.5
    min_num_points = 200,        
    
    --Points far away from the origin by more than max_range are removed
    max_range = 50.,             
  },

  -- Adaptive voxel filter for closed-loop detection, used to generate sparse point clouds for closed-loop detection
  loop_closure_adaptive_voxel_filter = {
    max_length = 0.9,
    min_num_points = 100,
    max_range = 50.,
  },



  
  use_online_correlative_scan_matching = false,
  --use_online_correlative_scan_matching = true，This configuration is very important. If you don't configure this, the mapping effect will be very poor.
--If this item is false, the scan matching uses a priori through the position of the previous frame, compares the current scan with the previous one,
-- and uses the Gauss-Newton method to iteratively solve the least squares problem to obtain the coordinate transformation of the current scan;
--If this item is true, the real-time closed-loop detection method is used to perform front-end scan matching, and the current scan is searched
-- within a certain search range, the range is the set translation distance and angle, and then the scan is inserted into the matching The best location.
--After set to true, the effect of mapping is very good, even if there is drift in the mapping, it can be corrected back, but the computational complexity is very high and it consumes CPU

  real_time_correlative_scan_matcher = {

    --The smallest linear search window to find the best scan match
    linear_search_window = 0.1,    
    
    --The smallest angle search window to find the best scan match
    angular_search_window = math.rad(20.),  

    --Used to calculate the weight of each part of the score
    translation_delta_cost_weight = 1e-1,   
    rotation_delta_cost_weight = 1e-1,
  },



  ceres_scan_matcher = {
    --The scale factor of each cost factor takes up space weight
    occupied_space_weight = 1.,
    translation_weight = 10.,
    rotation_weight = 40.,
    ceres_solver_options = {
      use_nonmonotonic_steps = false,
      max_num_iterations = 20,
      num_threads = 1,
    },
  },

  
  -- In order to prevent too much data from being inserted into the subgraph, 
  --filter the data before inserting the subgraph
  motion_filter = {
    max_time_seconds = 5.,
    max_distance_meters = 0.2,
    max_angle_radians = math.rad(1.),
  },

  -- TODO(schwoere,wohe): Remove this constant. This is only kept for ROS.
  --Observe 10s through imu while moving to determine the average direction of gravity
  imu_gravity_time_constant = 10.,

  
  pose_extrapolator = {
    use_imu_based = false,
    constant_velocity = {-
      imu_gravity_time_constant = 10.,
      pose_queue_duration = 0.001,
    },
    imu_based = {
      pose_queue_duration = 5.,
      gravity_constant = 9.806,
      pose_translation_weight = 1.,
      pose_rotation_weight = 1.,
      imu_acceleration_weight = 1.,
      imu_rotation_weight = 1.,
      odometry_translation_weight = 1.,
      odometry_rotation_weight = 1.,
      solver_options = {
        use_nonmonotonic_steps = false;
        max_num_iterations = 10;
        num_threads = 1;
      },
    },
  },

  
  --Usually only num_range_data may be modified
  
  submaps = {
    
    --Half of the number of radar data inserted in a subgraph
    num_range_data = 90,

    grid_options_2d = {
      grid_type = "PROBABILITY_GRID", 
      resolution = 0.05,--Grid size
    },
    range_data_inserter = {
      range_data_inserter_type = "PROBABILITY_GRID_INSERTER_2D",

      probability_grid_range_data_inserter = {



        insert_free_space = true,
        hit_probability = 0.55,
        miss_probability = 0.49,
      },
      
      tsdf_range_data_inserter = {
        truncation_distance = 0.3,
        maximum_weight = 10.,
        update_free_space = false,
        normal_estimation_options = {
          num_normal_samples = 4,
          sample_radius = 0.5,
        },
        project_sdf_distance_to_scan_normal = true,
        update_weight_range_exponent = 0,
        update_weight_angle_scan_normal_to_ray_kernel_bandwidth = 0.5,
        update_weight_distance_cell_to_hit_kernel_bandwidth = 0.5,
      },
    },
  },
  


}
