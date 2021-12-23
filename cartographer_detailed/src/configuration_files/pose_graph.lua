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

POSE_GRAPH = {

  --If it is set to 0, the global SLAM is manually turned off, 
  --and the main focus is on local SLAM. This is the first thing to debug cartographer
  -- How many nodes to perform back-end optimization
  optimize_every_n_nodes = 90,

  
  constraint_builder = {

    -- The calculation frequency when loopback detection is performed on the partial 
    --subgraph, the larger the value, the more calculation times
    sampling_ratio = 0.3,                 

    --The maximum distance that can be constrained when performing loopback detection 
    --on local subgraphs
    max_constraint_distance = 15.,        

    --The lowest score threshold for loop detection of local subgraphs
    min_score = 0.55,                   

    --The lowest score threshold for loop detection of the overall subgraph
    global_localization_min_score = 0.6,  

    --The weight of the translation of the closed-loop constraint in the optimization problem
    loop_closure_translation_weight = 1.1e4,

    loop_closure_rotation_weight = 1e5,
    
    --Non-global constraints (also called sub-map internal constraints) are automatically established
    -- between nodes, which are relatively close nodes on the trajectory.
    --Intuitively, these non-global constraints maintain the interconnection of the trajectory.

    --Global constraints (also called loopback detection constraints or constraints between sub-maps) 
    --are usually searched between a new sub-map and the previous node.
    --Those previous nodes are close enough in space (partly in a search window). Intuitively, these 
    --global constraints introduce a knot (knotting) in the structure, which fixes the two sub-maps 
    --closer together.

    --Get the log of constraints builder (closed loop constraints), the default is true.
    log_matches = true,

  
    -- 2d rough matcher based on branch and bound algorithm
    fast_correlative_scan_matcher = {
      
      --Rely on the "branch and bound" mechanism to work under
      -- different grid resolutions and effectively eliminate incorrect matches
      linear_search_window = 7.,

      --Once a good enough score is found (above the minimum matching score), 
      --it (scan) is sent to the Ceres scan matcher to optimize the pose.
      angular_search_window = math.rad(30.),

      --At least 1, it should be the larger the value, the stronger the role of the backend
      branch_and_bound_depth = 7,
    },

    
    
    -- 2d precise matcher based on ceres
    ceres_scan_matcher = {
      occupied_space_weight = 20.,
      translation_weight = 10.,
      rotation_weight = 1.,
      ceres_solver_options = {
        use_nonmonotonic_steps = true,
        max_num_iterations = 10,
        num_threads = 1,
      },
    },

    -- 3D rough matcher based on branch and bound algorithm
    fast_correlative_scan_matcher_3d = {
      branch_and_bound_depth = 8,
      full_resolution_depth = 3,
      min_rotational_score = 0.77,
      min_low_resolution_score = 0.55,
      linear_xy_search_window = 5.,
      linear_z_search_window = 1.,
      angular_search_window = math.rad(15.),
    },

    -- 3d precise matcher based on ceres
    ceres_scan_matcher_3d = {
      occupied_space_weight_0 = 5.,
      occupied_space_weight_1 = 30.,
      translation_weight = 10.,
      rotation_weight = 1.,
      only_optimize_yaw = false,
      ceres_solver_options = {
        use_nonmonotonic_steps = false,
        max_num_iterations = 10,
        num_threads = 1,
      },
    },
  },

  matcher_translation_weight = 5e2,
  matcher_rotation_weight = 1.6e3,

  --Parameter configuration of residual equation
  optimization_problem = {

    
    huber_scale = 1e1,                -- The larger the value, the greater the impact of the (potential) outlier
    acceleration_weight = 1.1e2,      -- The weight of the linear acceleration of imu in 3d
    rotation_weight = 1.6e4,          -- The weight of the rotation of the imu in 3d
    
    --Weight of translation between consecutive nodes based on local SLAM pose
    -- The weight of the front-end result residual
    local_slam_pose_translation_weight = 1e5,
    local_slam_pose_rotation_weight = 1e5,
    
    
    -- Weight of odometer residuals
    odometry_translation_weight = 1e5,
    odometry_rotation_weight = 1e5,
    -- gps residual weight
    fixed_frame_pose_translation_weight = 1e1,
    fixed_frame_pose_rotation_weight = 1e2,
    fixed_frame_pose_use_tolerant_loss = false,
    fixed_frame_pose_tolerant_loss_param_a = 1,
    fixed_frame_pose_tolerant_loss_param_b = 1,

    --The results of Ceres global optimization can be 
    --recorded and used to improve your external calibration
    log_solver_summary = false,

    --As part of the IMU residual
    use_online_imu_extrinsics_in_3d = true,
    fix_z_in_3d = false,
    ceres_solver_options = {
      use_nonmonotonic_steps = false,
      max_num_iterations = 50,
      num_threads = 7,
    },
  },

  --A new global optimization will be run after the completion of the mapping, 
  --which does not require real-time performance and has a large number of iterations
  max_num_final_iterations = 200,   
  global_sampling_ratio = 0.003,    -- Find the frequency of loopback during pure positioning
  log_residual_histograms = true,

  -- How many seconds to perform the constraint calculation of the whole subgraph in pure positioning
  global_constraint_search_after_n_seconds = 10., 

  --  overlapping_submaps_trimmer_2d = {
  --    fresh_submaps_count = 1,
  --    min_covered_area = 2,
  --    min_added_submaps_count = 5,
  --  },

  --------------------------------------------------------------------------------------
  --If local SLAM uses a separate odometry (use_odometry = true), we can adjust the global SLAM accordingly
  --There are four parameters that allow us to adjust the individual weights of local SLAM and odometer in optimization:

  --POSE_GRAPH.optimization_problem.local_slam_pose_translation_weight
  --POSE_GRAPH.optimization_problem.local_slam_pose_rotation_weight
  --POSE_GRAPH.optimization_problem.odometry_translation_weight
  --POSE_GRAPH.optimization_problem.odometry_rotation_weight

  --These weights can be set according to our trust in local SLAM or odometry. By default, the odometer is weighted 
  --into a global optimization similar to the local slam (scan matching) pose.
  --However, the rotation from the wheel odometer usually has a high uncertainty, so the rotation weight can be reduced, or even reduced to 0
}
