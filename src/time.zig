pub var time: f64 = 0;
pub var delta: f32 = 0;

pub fn update_time(dt: f32) void {
    delta = dt * 0.001;
    time += delta;
}
