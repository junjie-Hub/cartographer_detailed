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

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",--submaps의ROS좌표계를 발표，자태의 부좌표계，보통은 map 
  tracking_frame = "horizontal_laser_link",-- 일반적으로 IMU 사용하면 imu_link로 설정.아니면base_link로 설정
  
  -- 자태의 하위 좌표계의 ROS 좌표계
  published_frame = "horizontal_laser_link",

  --provide_odom_frame는 true로 설정할 때 odom_frame이 활성화될 수 있다.
  odom_frame = "odom",
  provide_odom_frame = true,
  
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,

  --true로 설정하면 odom 이슈 (또는 다른 이름) 의 nav_msgs/ Odometry 메세지를 구독한다.
  --Odometer 정보를 제공해야 하며, 이 정보는 SLAM에 포함되어 있다
  use_odometry = false,

  --gps 사용하는 것을 설정
  use_nav_sat = false,

  --landmarks 사용하는 것을 설정
  use_landmarks = false,

  --laser number
  num_laser_scans = 1,

  --laser의 종류에 따라 설정,여기는 0로 설정
  num_multi_echo_laser_scans = 0,

  --laser의 종류에 따라 설정,여기는 1로 설정
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 0,

  --tf2를 사용하여 변경된 시간초과 시간을 찾다
  lookup_transform_timeout_sec = 0.2,

  --Publish submap interval
  submap_publish_period_sec = 0.3,

  --Cartographer publishes the interval of tf transformation
  pose_publish_period_sec = 5e-3,

  --Time interval for posting track markers
  trajectory_publish_period_sec = 30e-3,

  --Weight ratio of 5 observations
  rangefinder_sampling_ratio = 1.,--Fixed rate sampling of rangefinder messages
  
  odometry_sampling_ratio = 1.,--Fixed rate sampling of odometer messages. For example, 
  --the data of odom is very inaccurate, and it can be set to 0.3 to reduce the influence 
  --of odom on the overall optimization.
  
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
}


--Choose to use 2D or 3D
MAP_BUILDER.use_trajectory_builder_2d = true



TRAJECTORY_BUILDER_2D.submaps.num_range_data = 35
TRAJECTORY_BUILDER_2D.min_range = 0.3
TRAJECTORY_BUILDER_2D.max_range = 8.
TRAJECTORY_BUILDER_2D.missing_data_ray_length = 1.
TRAJECTORY_BUILDER_2D.use_imu_data = false
TRAJECTORY_BUILDER_2D.use_online_correlative_scan_matching = true
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.linear_search_window = 0.1
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.translation_delta_cost_weight = 10.
TRAJECTORY_BUILDER_2D.real_time_correlative_scan_matcher.rotation_delta_cost_weight = 1e-1

POSE_GRAPH.optimization_problem.huber_scale = 1e2
POSE_GRAPH.optimize_every_n_nodes = 35
POSE_GRAPH.constraint_builder.min_score = 0.65

return options
