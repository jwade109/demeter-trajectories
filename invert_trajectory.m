function inverted = invert_trajectory(traj)

inverted = traj;

inverted.final = traj.initial;
inverted.final.epoch = traj.final.epoch;

inverted.initial = traj.final;
inverted.initial.epoch = traj.initial.epoch;

inverted.path = flip(traj.path);

end