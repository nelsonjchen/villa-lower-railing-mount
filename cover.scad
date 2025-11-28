// --- Parametric Wire Cover Mount ---
// Status: Box is a CAP.
// - Front (facing room) is SOLID and ROUNDED (Top & Sides).
// - Back (facing posts/wires) is OPEN and SQUARE.
// - Top is SOLID.
// - Bottom is OPEN (Fixed rendering artifact).
// - Includes Baseboard Notches (Fixed visibility).
// - Includes Reinforcement Blocks.
// - Includes Central Bridge.

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
notch_depth = 0.5 * inch;    // Depth of the cutout from the back wall (Y)

// Rounding Dimensions
rounding_radius = 5.0;        // Radius for the front edges

// Tolerance
clearance = 0.2;
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
        // 1. Back Face (Square) at Y = 0 (relative to local origin)
        translate([-w/2, 0, -h/2]) cube([w, 0.1, h]);
        
        // 2. Front Face (Rounded Edges) at Y = -d
        // Top-Left Corner
        translate([-w/2 + r, -d + r, h/2 - r]) sphere(r=r);
        // Top-Right Corner
        translate([w/2 - r, -d + r, h/2 - r]) sphere(r=r);
        // Bottom-Left Corner
        translate([-w/2 + r, -d + r, -h/2]) cylinder(r=r, h=0.1);
        // Bottom-Right Corner
        translate([w/2 - r, -d + r, -h/2]) cylinder(r=r, h=0.1);
    }
}

module wire_cover_mount() {
    union() {
        // 1. THE MAIN HOLLOW BOX (The Cap)
        difference() {
            // A. Positive Shape
            translate([0, 0, 0])
                rounded_front_box(total_width, mount_depth, mount_height, rounding_radius);
            
            // B. Negative Shape (Hollowout)
            // Extends much lower to prevent bottom artifacts
            hull() {
                $iw = total_width - 2*wall_thickness;
                $ir = rounding_radius - wall_thickness;
                $id = mount_depth - wall_thickness;
                
                // Z-LIMITS
                $z_top = mount_height/2 - wall_thickness;
                // Extend 50mm down to guaranteed clear the bottom
                $z_bottom = -mount_height/2 - 50.0; 
                
                // 1. Back Face Cutout
                translate([- $iw/2, overlap, $z_bottom]) 
                    cube([$iw, 0.1, $z_top - $z_bottom]); 
                
                // 2. Front Face Cutout
                translate([- $iw/2 + $ir, -$id + $ir, $z_top - $ir]) sphere(r=$ir);
                translate([$iw/2 - $ir, -$id + $ir, $z_top - $ir]) sphere(r=$ir);
                translate([- $iw/2 + $ir, -$id + $ir, $z_bottom]) cylinder(r=$ir, h=0.1);
                translate([$iw/2 - $ir, -$id + $ir, $z_bottom]) cylinder(r=$ir, h=0.1);
            }

            // C. Baseboard Notches (Simplified Cubes)
            // Left Notch
            // Starts outside X, outside Y (back), and outside Z (bottom)
            translate([
                -total_width/2 - 5,        // X: Start well outside
                -notch_depth,              // Y: Start at cut depth
                -mount_height/2 - 5        // Z: Start well below
            ])
            cube([
                wall_thickness + 10,       // Width: Cut inward past wall
                notch_depth + 5,           // Depth: Cut backward past Y=0
                notch_height + 5           // Height: Cut upward to notch height
            ]);

            // Right Notch
            translate([
                total_width/2 - wall_thickness - 0.1, // X: Start just inside right wall
                -notch_depth,
                -mount_height/2 - 5
            ])
            cube([
                wall_thickness + 10,       // Width: Cut outward
                notch_depth + 5, 
                notch_height + 5
            ]);
        }

        // 2. THE CLAMPS
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
                [wall_thickness, leg_length],
                [wall_thickness + lip_width, leg_length + wall_thickness],
                [0, leg_length + wall_thickness]
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
                [wall_thickness, leg_length],
                [wall_thickness + lip_width, leg_length + wall_thickness],
                [0, leg_length + wall_thickness]
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