// --- Parametric Wire Cover Mount ---
// Status: Box is a CAP.
// - Front (facing room) is SOLID.
// - Back (facing posts/wires) is OPEN.
// - Top is SOLID.
// - Bottom is OPEN.

// --- Dimensions ---
inch = 25.4;

// Post Dimensions
post_size = 0.5 * inch;
post_gap_inches = 3.6;
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_depth = 40;             // Y-axis: How far out the box sticks
mount_height = 120;           // Z-axis: Vertical length
clamp_height = 20;            // Z-axis: Width of the clip band
lip_width = 3;
wall_thickness = 3;
rail_offset = 3;

// Tolerance
clearance = 1.0;
overlap = 0.1;

// --- Calculations ---
total_width = post_gap + (2 * post_size) + (2 * wall_thickness) + (2 * clearance) + (2 * rail_offset);
post_start_x = post_gap / 2;
leg_length = post_size + wall_thickness + (clearance * 2);

$fn = 50;

module wire_cover_mount() {
    union() {
        // 1. THE MAIN HOLLOW BOX (The Cap)
        difference() {
            // A. Outer Shell
            // Y goes from -40 to 0 (0 is the face touching the clamps)
            translate([-total_width/2, -mount_depth, -mount_height/2])
                cube([total_width, mount_depth, mount_height]);

            // B. Inner Cavity (The Cutout)
            translate([
                -total_width/2 + wall_thickness, // Inside Left Wall
                -mount_depth + wall_thickness,   // Inside Front Face (Keep Front Solid)
                -mount_height/2 - overlap        // Start BELOW Bottom (Cut Floor Open)
            ])
            cube([
                total_width - (2 * wall_thickness),
                mount_depth + overlap,                  // Cut all the way out the BACK
                mount_height - wall_thickness + overlap // Cut upwards, Stop before Ceiling (Keep Top Solid)
            ]);
        }

        // 2. THE CLAMPS
        // Attached to the back rim (Y=0), extending towards posts (Positive Y)

        // Left Clamp
        translate([
            -post_start_x - post_size - wall_thickness - clearance,
            0, // Starts at back rim of box
            mount_height/2 - clamp_height
        ])
        linear_extrude(clamp_height)
            polygon(points=[
                [0, 0],
                [wall_thickness, 0],
                [wall_thickness, leg_length],
                [wall_thickness + lip_width, leg_length + wall_thickness],
                [0, leg_length + wall_thickness]
            ]);

        // Right Clamp (Mirrored)
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
                [wall_thickness, leg_length],
                [wall_thickness + lip_width, leg_length + wall_thickness],
                [0, leg_length + wall_thickness]
            ]);
    }
}

// --- Render ---
color("skyblue") wire_cover_mount();

// --- Visual Ghost of Posts ---
// Shows how the cover fits OVER the area between posts
%union() {
    translate([-post_start_x - post_size, leg_length - post_size - clearance, -mount_height/2])
        color("orange") cube([post_size, post_size, mount_height + 20]);

    translate([post_start_x, leg_length - post_size - clearance, -mount_height/2])
        color("orange") cube([post_size, post_size, mount_height + 20]);
}