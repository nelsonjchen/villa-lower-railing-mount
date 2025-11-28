// --- Parametric Wire Cover Mount ---
// Status: Box is a CAP.
// - Front (facing room) is SOLID.
// - Back (facing posts/wires) is OPEN.
// - Top is SOLID.
// - Bottom is OPEN.
// - Includes Baseboard Notches (Bottom-Back corners).
// - Includes Reinforcement Blocks for Clamps.
// - Includes Central Bridge (Thin Roof Extension between posts).

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
wall_thickness = 1;
rail_offset = 3;

// Baseboard Cutout Dimensions
notch_height = 1.25 * inch;   // Height of the cutout (Z)
notch_depth = 0.25 * inch;    // Depth of the cutout from the back wall (Y)

// Tolerance
clearance = 0.2;
overlap = 0.1;
visor_clearance = 3.0;        // Increased clearance for the central bridge (to prevent binding)

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

            // C. Baseboard Notches (Bottom Back Corners)
            // Left Notch
            translate([
                -total_width/2 - overlap,      // Start outside Left Wall
                -notch_depth,                  // Start at notch depth (Y)
                -mount_height/2 - overlap      // Start at Bottom
            ])
            cube([
                wall_thickness + 2*overlap,    // Cut through the wall thickness
                notch_depth + overlap,         // Cut to the back edge
                notch_height + overlap         // Cut up to notch height
            ]);

            // Right Notch
            translate([
                total_width/2 - wall_thickness - overlap, // Start inside Right Wall
                -notch_depth,
                -mount_height/2 - overlap
            ])
            cube([
                wall_thickness + 2*overlap,
                notch_depth + overlap,
                notch_height + overlap
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

        // 3. REINFORCEMENT BLOCKS (Adhesion)
        // These blocks bridge the 'rail_offset' gap, connecting the clamps solidly to the side walls.

        // Left Reinforcement
        translate([
            -total_width/2 + wall_thickness - overlap, // Start at inner wall
            -wall_thickness,                           // Start slightly inside the box (anchoring)
            mount_height/2 - clamp_height              // Same Z height
        ])
        cube([
            rail_offset + overlap,                     // Width to reach the clamp
            wall_thickness * 2,                        // Depth (overlaps box and clamp start)
            clamp_height                               // Height
        ]);

        // Right Reinforcement
        translate([
            total_width/2 - wall_thickness - rail_offset, // Start at clamp edge
            -wall_thickness,
            mount_height/2 - clamp_height
        ])
        cube([
            rail_offset + overlap,
            wall_thickness * 2,
            clamp_height
        ]);

        // 4. CENTRAL BRIDGE (Covers area between posts)
        // Thin Roof Extension: Extends the top surface between the posts.
        // Uses 'visor_clearance' to ensure it doesn't bind against the posts.
        translate([
            -post_start_x + visor_clearance,   // Start further in
            0,                                 // Start at box face
            mount_height/2 - wall_thickness    // Flush with the TOP surface
        ])
        cube([
            post_gap - (2 * visor_clearance),  // Narrower width
            leg_length,                        // Depth: Reach as far as the legs
            wall_thickness                     // Height: Thin wall (Roof)
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