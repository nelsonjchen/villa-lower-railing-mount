// --- Parametric Wire Cover Mount (Fixed Snap-Fit) ---
// Status: Snap-fit added to clamps.

// --- Dimensions ---
inch = 25.4;

// Post Dimensions
post_size = 0.5 * inch;
post_gap_inches = 3.6;
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_depth = 20;             // Y-axis: How far out the box sticks
mount_height = 120;           // Z-axis: Vertical length
clamp_height = 20;            // Z-axis: Width of the clip band
lip_width = 4;                // How deep the hook grabs
lead_in_length = 5;           // Length of the angled ramp tip
wall_thickness = 1.6;
rail_offset = 3;

// Baseboard Cutout Dimensions
notch_height = 1.25 * inch;
notch_depth = 0.5 * inch;

// Rounding Dimensions
rounding_radius = 5.0;

// Tolerance
clearance = 1.0;
overlap = 0.1;
visor_clearance = 3.0;

// --- Calculations ---
total_width = post_gap + (2 * post_size) + (2 * wall_thickness) + (2 * clearance) + (2 * rail_offset);
post_start_x = post_gap / 2;
leg_length = post_size + wall_thickness + (clearance * 2);

$fn = 50;

// Helper Module: Creates a box with a rounded Front Face but Square Back Face
module rounded_front_box(w, d, h, r) {
    hull() {
        translate([-w/2, 0, -h/2]) cube([w, 0.1, h]);
        translate([-w/2 + r, -d + r, h/2 - r]) sphere(r=r);
        translate([w/2 - r, -d + r, h/2 - r]) sphere(r=r);
        translate([-w/2 + r, -d + r, -h/2]) cylinder(r=r, h=0.1);
        translate([w/2 - r, -d + r, -h/2]) cylinder(r=r, h=0.1);
    }
}

module wire_cover_mount() {
    union() {
        // 1. THE MAIN HOLLOW BOX
        difference() {
            translate([0, 0, 0])
                rounded_front_box(total_width, mount_depth, mount_height, rounding_radius);

            hull() {
                $iw = total_width - 2*wall_thickness;
                $ir = rounding_radius - wall_thickness;
                $id = mount_depth - wall_thickness;
                $z_top = mount_height/2 - wall_thickness;
                $z_bottom = -mount_height/2 - 50.0;

                translate([- $iw/2, overlap, $z_bottom])
                    cube([$iw, 0.1, $z_top - $z_bottom]);

                translate([- $iw/2 + $ir, -$id + $ir, $z_top - $ir]) sphere(r=$ir);
                translate([$iw/2 - $ir, -$id + $ir, $z_top - $ir]) sphere(r=$ir);
                translate([- $iw/2 + $ir, -$id + $ir, $z_bottom]) cylinder(r=$ir, h=0.1);
                translate([$iw/2 - $ir, -$id + $ir, $z_bottom]) cylinder(r=$ir, h=0.1);
            }

            // Baseboard Notches
            translate([-total_width/2 - 5, -notch_depth, -mount_height/2 - 5])
            cube([wall_thickness + 10, notch_depth + 5, notch_height + 5]);

            translate([total_width/2 - wall_thickness - 0.1, -notch_depth, -mount_height/2 - 5])
            cube([wall_thickness + 10, notch_depth + 5, notch_height + 5]);
        }

        // 2. THE CLAMPS (UPDATED SHAPE)
        // Left Clamp
        translate([
            -post_start_x - post_size - wall_thickness - clearance,
            0,
            mount_height/2 - clamp_height
        ])
        linear_extrude(clamp_height)
            polygon(points=[
                [0, 0],
                [wall_thickness, 0],
                [wall_thickness, leg_length],                // Base of Hook
                [wall_thickness + lip_width, leg_length],    // The Barb (Locks behind post)
                [wall_thickness, leg_length + lead_in_length], // The Tip (Ramp for sliding on)
                [0, leg_length + lead_in_length]             // Outer Tip
            ]);

        // Right Clamp
        translate([
            post_start_x + post_size + clearance + wall_thickness,
            0,
            mount_height/2 - clamp_height
        ])
        mirror([1,0,0])
        linear_extrude(clamp_height)
            polygon(points=[
                [0, 0],
                [wall_thickness, 0],
                [wall_thickness, leg_length],                // Base of Hook
                [wall_thickness + lip_width, leg_length],    // The Barb (Locks behind post)
                [wall_thickness, leg_length + lead_in_length], // The Tip (Ramp for sliding on)
                [0, leg_length + lead_in_length]             // Outer Tip
            ]);

        // 3. REINFORCEMENT BLOCKS
        translate([-total_width/2 + wall_thickness - overlap, -wall_thickness, mount_height/2 - clamp_height])
            cube([rail_offset + overlap, wall_thickness * 2, clamp_height]);

        translate([total_width/2 - wall_thickness - rail_offset, -wall_thickness, mount_height/2 - clamp_height])
            cube([rail_offset + overlap, wall_thickness * 2, clamp_height]);

        // 4. CENTRAL BRIDGE
        translate([-post_start_x + visor_clearance, 0, mount_height/2 - wall_thickness])
            cube([post_gap - (2 * visor_clearance), leg_length, wall_thickness]);
    }
}

// --- Render ---
color("skyblue") wire_cover_mount();

// --- Visual Ghost of Posts ---
%union() {
    translate([-post_start_x - post_size, leg_length - post_size - clearance, -mount_height/2])
        color("orange") cube([post_size, post_size, mount_height + 20]);
    translate([post_start_x, leg_length - post_size - clearance, -mount_height/2])
        color("orange") cube([post_size, post_size, mount_height + 20]);
}