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
lip_width = 3;                // Reduced from 1/4 inch to ~3mm for easier clamping
wall_thickness = 3;           // Reduced from 6mm to 3mm for flexibility

// Bolt Dimensions
bolt_spacing = 52;            // Updated to 52mm
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
            translate([-total_width/2, -mount_depth/2, 0])
                cube([total_width, mount_depth, mount_thickness]);

            // B. Left Clamp Logic
            translate([-post_start_x - post_size - wall_thickness - clearance, -mount_depth/2, -leg_height]) {
                // Side Wall
                cube([wall_thickness, mount_depth, leg_height + overlap]);

                // Bottom Hook (Triangular Wedge)
                // Positioned at the bottom of the wall, pointing inwards (Right/+X)
                translate([wall_thickness, mount_depth, 0])
                    rotate([90, 0, 0]) // Rotate to extrude along Y
                    linear_extrude(mount_depth)
                    polygon([
                        [0, 0],                         // Bottom-left (at wall connection)
                        [lip_width, wall_thickness],    // Tip-top (Sharp edge)
                        [0, wall_thickness]             // Top-left (at wall connection)
                    ]);
            }

            // C. Right Clamp Logic
            translate([post_start_x + post_size + clearance, -mount_depth/2, -leg_height]) {
                // Side Wall
                cube([wall_thickness, mount_depth, leg_height + overlap]);

                // Bottom Hook (Triangular Wedge)
                // Positioned at the bottom, pointing inwards (Left/-X)
                translate([0, mount_depth, 0])
                    rotate([90, 0, 0])
                    linear_extrude(mount_depth)
                    polygon([
                        [0, 0],                         // Bottom-right (at wall connection)
                        [-lip_width, wall_thickness],   // Tip-top (Sharp edge)
                        [0, wall_thickness]             // Top-right (at wall connection)
                    ]);
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

    // Distance Marker (Visual aid for checking bolt spacing)
    translate([-bolt_spacing/2, 0, mount_thickness + 2])
        color("red") cylinder(h=2, d=2);
    translate([bolt_spacing/2, 0, mount_thickness + 2])
        color("red") cylinder(h=2, d=2);
}