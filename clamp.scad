// --- Parametric Mount Bracket ---
// Based on user sketch specifications

// --- Dimensions (Change these if needed) ---
inch = 25.4; // Conversion factor

// Post Dimensions
post_size = 0.5 * inch; // 1/2 inch square posts
post_gap_inches = 3.6; // 3 and 6/10 inches between posts
post_gap = post_gap_inches * inch;

// Mount Dimensions
mount_thickness = 5; // "1cm thickness of mount" (Vertical thickness of main bar)
mount_depth = 20; // How wide the bracket is (Y-axis length)
lip_width = 3; // ~3mm for easier clamping
wall_thickness = 3; // 3mm for flexibility

// Camera Mount Dimensions
extension_height = 85; // Extended +Z 85mm for the camera holes

// Bolt Dimensions
bolt_spacing = 52; // 52mm spacing for the camera mount
bolt_diameter = 4.4; // M4 screw (4mm + 0.4mm clearance)

// Tolerance / Clearance
clearance = 1.0;
overlap = 0.1;

// --- Calculations ---
total_width = post_gap + (2 * post_size) + (2 * wall_thickness);
post_start_x = post_gap / 2;
leg_height = post_size + wall_thickness + (clearance * 2);

$fn = 60; // Smooth resolution

module bracket_base() {
  // Top Bar (Main Span) with filleted transitions
  hull() {
    translate([-total_width / 2, -mount_depth / 2, 0])
      cube([total_width, mount_depth, mount_thickness]);

    // Smooth transition to the legs to eliminate "jank"
    translate([-post_start_x - post_size - wall_thickness - clearance, -mount_depth / 2, -5])
      cube([wall_thickness, mount_depth, 5]);
    translate([post_start_x + post_size + clearance, -mount_depth / 2, -5])
      cube([wall_thickness, mount_depth, 5]);
  }

  // Left Clamp Leg (Fits over the post)
  translate([-post_start_x - post_size - wall_thickness - clearance, -mount_depth / 2, -leg_height]) {
    cube([wall_thickness, mount_depth, leg_height]);

    // Bottom Hook (Tapered correctly for 3D printing without supports to fix the jank)
    translate([wall_thickness, mount_depth, 0])
      rotate([90, 0, 0])
        linear_extrude(mount_depth)
          polygon(
            [
              [0, 0],
              [lip_width, lip_width], // Symmetric point for 45 deg overhang
              [0, lip_width * 2], // Ensures it seals against wall safely
            ]
          );
  }

  // Right Clamp Leg (Fits over the post)
  translate([post_start_x + post_size + clearance, -mount_depth / 2, -leg_height]) {
    cube([wall_thickness, mount_depth, leg_height]);

    // Bottom Hook (Tapered)
    translate([0, mount_depth, 0])
      rotate([90, 0, 0])
        linear_extrude(mount_depth)
          polygon(
            [
              [0, 0],
              [-lip_width, lip_width],
              [0, lip_width * 2],
            ]
          );
  }
}

module mount() {
  difference() {
    // --- Solid Bodies ---
    union() {
      // Include the modified base clamping bracket
      bracket_base();

      // Add the +Z 85mm Extension Tower
      // We'll make it an elegant A-frame style tower for strength and aesthetics
      hull() {
        // Base of the tower covering the center span
        translate([-post_start_x, -mount_depth / 2, 0])
          cube([post_gap, mount_depth, mount_thickness]);

        // Top Mount plate for camera holes (+Z 85mm)
        translate([-(bolt_spacing + 24) / 2, -mount_depth / 2, extension_height])
          cube([bolt_spacing + 24, mount_depth, mount_thickness]);
      }
    }

    // --- Bolt Holes Subtraction ---
    // Left camera hole at the top
    translate([-bolt_spacing / 2, 0, extension_height - 5])
      cylinder(h=mount_thickness + 10, d=bolt_diameter);

    // Right camera hole at the top
    translate([bolt_spacing / 2, 0, extension_height - 5])
      cylinder(h=mount_thickness + 10, d=bolt_diameter);

    // --- Make it an Arch by cutting out the center ---
    // Keeps it strong but saves material, looks gorgeous, and allows access for nuts/screws beneath holes
    hull() {
      // Bottom of the arch
      translate([-(post_start_x - 12), -mount_depth / 2 - 1, mount_thickness + 5])
        cube([(post_start_x - 12) * 2, mount_depth + 2, 0.1]);

      // Top of the arch, specifically sized to go directly UNDER the bolt holes
      // Allows standard screws / nuts to fit cleanly underneath the 5mm top plate
      translate([-(bolt_spacing / 2 + 6), -mount_depth / 2 - 1, extension_height])
        cube([(bolt_spacing / 2 + 6) * 2, mount_depth + 2, 0.1]);
    }
  }
}

// --- Render the Part ---
color("lightgrey") mount();

// --- Visual Ghost of the Posts (For debugging/Checking fit) ---
%union() {
  // Left Post
  translate([-post_start_x - post_size, -mount_depth / 2 - 10, -post_size - clearance])
    color("orange") cube([post_size, mount_depth + 20, post_size]);

  // Right Post
  translate([post_start_x, -mount_depth / 2 - 10, -post_size - clearance])
    color("orange") cube([post_size, mount_depth + 20, post_size]);
}
