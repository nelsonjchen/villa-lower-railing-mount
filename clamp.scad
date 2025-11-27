// --- Parametric Mount Bracket ---
// Based on user sketch specifications

// --- Dimensions (Change these if needed) ---
inch = 25.4; // Conversion factor

// Post Dimensions
post_size = 0.5 * inch;       // 1/2 inch square posts
post_gap_inches = 3.6;        // 3 and 6/10 inches between posts
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_thickness = 10;         // "1cm thickness of mount" (Vertical thickness of main bar)
mount_depth = 20;             // How wide the bracket is (Y-axis length)
lip_width = 0.25 * inch;      // "1/4 inch" bottom hook length
wall_thickness = 6;           // Thickness of the side vertical walls and bottom hooks

// Bolt Dimensions
bolt_spacing = 41;            // 41 mm center-to-center
bolt_diameter = 4.4;          // M4 screw (4mm + 0.4mm clearance)

// Tolerance / Clearance
// Add a small gap so it slides easily onto the real world posts.
// Increase this if your printer prints "tight".
clearance = 0.4;

// Overlap for boolean operations
// Tiny overlap to prevent "Z-fighting" (flickering seams) in preview
overlap = 0.1;

// --- Calculations (Do not edit unless you know what you're doing) ---
total_width = post_gap + (2 * post_size) + (2 * wall_thickness);
center_offset = total_width / 2;

// The X coordinate where the inner edge of the post starts
post_start_x = post_gap / 2;

// The total height of the side legs (Post height + bottom lip thickness)
leg_height = post_size + wall_thickness + (clearance * 2);

$fn = 50; // Resolution for circles

module mount() {
    difference() {
        // 1. The Main Body Union
        union() {
            // A. Top Bar (Main Span)
            // Spans the entire width including walls
            translate([-total_width/2, -mount_depth/2, 0])
                cube([total_width, mount_depth, mount_thickness]);

            // B. Left Clamp Logic
            translate([-post_start_x - post_size - wall_thickness - clearance, -mount_depth/2, -leg_height]) {
                // Side Wall
                // Added +overlap to height so it merges into the top bar
                cube([wall_thickness, mount_depth, leg_height + overlap]);

                // Bottom Lip (Hook)
                cube([wall_thickness + lip_width, mount_depth, wall_thickness]);
            }

            // C. Right Clamp Logic
            translate([post_start_x + post_size + clearance, -mount_depth/2, -leg_height]) {
                // Side Wall
                // Added +overlap to height so it merges into the top bar
                cube([wall_thickness, mount_depth, leg_height + overlap]);

                // Bottom Lip (Hook) - Needs to point inward, so we shift X back
                translate([-lip_width, 0, 0])
                    cube([wall_thickness + lip_width, mount_depth, wall_thickness]);
            }
        }

        // 2. Bolt Holes Subtraction
        // Left Hole
        translate([-bolt_spacing/2, 0, -1])
            cylinder(h = mount_thickness + 2, d = bolt_diameter);

        // Right Hole
        translate([bolt_spacing/2, 0, -1])
            cylinder(h = mount_thickness + 2, d = bolt_diameter);
    }
}

// --- Render the Part ---
color("lightgrey") mount();

// --- Visual Ghost of the Posts (For debugging/Checking fit) ---
// This won't be exported to STL, just for viewing in OpenSCAD
%union() {
    // Left Post
    translate([-post_start_x - post_size, -mount_depth/2 - 10, -post_size - clearance])
        color("orange") cube([post_size, mount_depth + 20, post_size]);

    // Right Post
    translate([post_start_x, -mount_depth/2 - 10, -post_size - clearance])
        color("orange") cube([post_size, mount_depth + 20, post_size]);

    // Distance Marker (Visual aid for checking 41mm)
    translate([-bolt_spacing/2, 0, mount_thickness + 2])
        color("red") cylinder(h=2, d=2);
    translate([bolt_spacing/2, 0, mount_thickness + 2])
        color("red") cylinder(h=2, d=2);
}