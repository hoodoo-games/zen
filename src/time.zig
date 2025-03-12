pub var time: f64 = 0;
pub var delta: f32 = 0;

pub fn update_time(dt: f32) void {
    time += dt;
    delta = dt;
}
