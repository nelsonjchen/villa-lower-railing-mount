// --- Parametric Wire Cover Mount ---
// Modified: Removed bolt holes.
// Clamps remain on the ENCLOSED side (High Y).

// --- Dimensions ---
inch = 25.4;

// Post Dimensions
post_size = 0.5 * inch;
post_gap_inches = 3.6;
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_thickness = 100;        // Height of the box
mount_depth = 120;            // Depth of the box
clamp_depth = 20;             // Depth of the clamps only
lip_width = 3;
wall_thickness = 3;           // Thickness of the shell walls

// Tolerance
clearance = 1.0;
overlap = 0.1;

// --- Calculations ---
// Width must now include clearance so the box walls sit on top of the clamps
total_width = post_gap + (2 * post_size) + (2 * wall_thickness) + (2 * clearance);
post_start_x = post_gap / 2;
leg_height = post_size + wall_thickness + (clearance * 2);

$fn = 50;

module wire_cover_mount() {
    // Removed the outer difference() since we no longer have bolt holes to subtract
    union() {
        // 1. THE MAIN HOLLOW BODY (The Shell)
        difference() {
            // A. Outer Cube
            translate([-total_width/2, -mount_depth/2, 0])
                cube([total_width, mount_depth, mount_thickness]);

            // B. Inner Cube (The Hollow part)
            // We cut away the inside, leaving walls on Top, Front, Left, Right
            // We leave the Bottom and Back OPEN for wires.
            translate([
                -total_width/2 + wall_thickness, // Start inside Left wall
                -mount_depth/2 - overlap,        // Start outside Back wall (to cut it open)
                -overlap                         // Start outside Bottom wall (to cut it open)
            ])
            cube([
                total_width - (2 * wall_thickness),      // Width between walls
                mount_depth - wall_thickness + overlap,  // Cut all the way except Front wall (High Y)
                mount_thickness - wall_thickness + overlap // Cut all the way except Top wall
            ]);
        }

        // 2. THE CLAMPS (Moved to ENCLOSED SIDE / High Y)
        // Left Clamp
        translate([
            -post_start_x - post_size - wall_thickness - clearance,
            mount_depth/2 - clamp_depth, // MOVED: Now at the positive Y end (enclosed side)
            -leg_height
        ]) {
            cube([wall_thickness, clamp_depth, leg_height + overlap]);
            translate([wall_thickness, clamp_depth, 0])
                rotate([90, 0, 0])
                linear_extrude(clamp_depth)
                polygon([[0, 0], [lip_width, wall_thickness], [0, wall_thickness]]);
        }

        // Right Clamp
        translate([
            post_start_x + post_size + clearance,
            mount_depth/2 - clamp_depth, // MOVED: Now at the positive Y end (enclosed side)
            -leg_height
        ]) {
            cube([wall_thickness, clamp_depth, leg_height + overlap]);
            translate([0, clamp_depth, 0])
                rotate([90, 0, 0])
                linear_extrude(clamp_depth)
                polygon([[0, 0], [-lip_width, wall_thickness], [0, wall_thickness]]);
        }
    }
}

// --- Render ---
color("skyblue") wire_cover_mount();

// --- Visual Ghost of Posts (For context - Showing new position) ---
%union() {
    translate([-post_start_x - post_size, mount_depth/2 - clamp_depth - 10, -post_size - clearance])
        color("orange") cube([post_size, clamp_depth + 20, post_size]);
    translate([post_start_x, mount_depth/2 - clamp_depth - 10, -post_size - clearance])
        color("orange") cube([post_size, clamp_depth + 20, post_size]);
}