// --- Parametric Wire Cover Mount ---
// Modified: REMOVED the "shoulder" spacers.
// The cover body remains offset (wider) to clear obstacles.
// The clamps are now thin, separate legs hanging from the top surface.
// Rotated 90 degrees for preview (Clips facing UP).

// --- Dimensions ---
inch = 25.4; 

// Post Dimensions
post_size = 0.5 * inch;       
post_gap_inches = 3.6;        
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_thickness = 40;         // Height of the box
mount_depth = 120;            // Depth of the box
clamp_depth = 20;             // Depth of the clamps only
lip_width = 3;                
wall_thickness = 3;           // Thickness of the shell walls
rail_offset = 3;              // Offset to clear other clamps (Creates gap between clamp and wall)

// Tolerance
clearance = 1.0;
overlap = 0.1;

// --- Calculations ---
// Width includes rail_offset so the box walls are further out (creating the clearance gap)
total_width = post_gap + (2 * post_size) + (2 * wall_thickness) + (2 * clearance) + (2 * rail_offset);
post_start_x = post_gap / 2;
leg_height = post_size + wall_thickness + (clearance * 2);

$fn = 50;

module wire_cover_mount() {
    union() {
        // 1. THE MAIN HOLLOW BODY (The Shell)
        // This shell is wider than the posts, creating the "offset"
        difference() {
            // A. Outer Cube
            translate([-total_width/2, -mount_depth/2, 0])
                cube([total_width, mount_depth, mount_thickness]);
            
            // B. Inner Cube (The Hollow part)
            translate([
                -total_width/2 + wall_thickness, // Start inside Left wall
                -mount_depth/2 - overlap,        // Start outside Back wall
                -overlap                         // Start outside Bottom wall
            ])
            cube([
                total_width - (2 * wall_thickness),      
                mount_depth - wall_thickness + overlap,  
                mount_thickness - wall_thickness + overlap 
            ]);
        }

        // 2. THE CLAMPS (Moved to ENCLOSED SIDE / High Y)
        // Fixed Position relative to Posts (Inner position)
        // They hang from the ceiling (Z = 0 plane in this local space)
        // Since the walls are offset outwards, these clamps hang "floating" inside the footprint.
        
        // --- Left Clamp ---
        translate([
            -post_start_x - post_size - wall_thickness - clearance, // Fixed Rail Position (Inner)
            mount_depth/2 - clamp_depth, 
            -leg_height // Extends down from the box
        ]) {
            // Vertical Leg (Thin, no spacer)
            cube([wall_thickness, clamp_depth, leg_height + overlap]);
            
            // Hook Geometry
            translate([wall_thickness, clamp_depth, 0]) 
                rotate([90, 0, 0]) 
                linear_extrude(clamp_depth)
                polygon([[0, 0], [lip_width, wall_thickness], [0, wall_thickness]]);
        }

        // --- Right Clamp ---
        translate([
            post_start_x + post_size + clearance, // Fixed Rail Position (Inner)
            mount_depth/2 - clamp_depth, 
            -leg_height
        ]) {
            // Vertical Leg (Thin, no spacer)
            cube([wall_thickness, clamp_depth, leg_height + overlap]);
            
            // Hook Geometry
            translate([0, clamp_depth, 0]) 
                rotate([90, 0, 0])
                linear_extrude(clamp_depth)
                polygon([[0, 0], [-lip_width, wall_thickness], [0, wall_thickness]]);
        }
    }
}

// --- Render (Rotated 90 degrees so clips are on TOP) ---
rotate([90, 0, 0]) {
    color("skyblue") wire_cover_mount();
}

// --- Visual Ghost of Posts (Rotated to match) ---
rotate([90, 0, 0]) {
    %union() {
        translate([-post_start_x - post_size, mount_depth/2 - clamp_depth - 10, -post_size - clearance])
            color("orange") cube([post_size, clamp_depth + 20, post_size]);
        translate([post_start_x, mount_depth/2 - clamp_depth - 10, -post_size - clearance])
            color("orange") cube([post_size, clamp_depth + 20, post_size]);
    }
}