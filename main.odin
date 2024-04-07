package ptable

import "core:fmt"

main :: proc() {
	pt, success := from_filename("README.md")	
	if !success {
		fmt.eprintln("failed to load file into piece table.");
		return
	}

	line0, _ := get_line(pt, 0)
	defer delete_string(line0)
	fmt.println("line: ", line0)

	insert(&pt, "</h2>", len(line0) - 1)
	remove(&pt, 0, 2);
	insert(&pt, "<h2>", 0)

	line1, _ := get_line(pt, 1)
	defer delete_string(line1)

	text1 := get_text(pt)
	defer delete_string(text1)
	fmt.println(text1)

	remove(&pt, 10, 20)

	text := get_text(pt)
	defer delete_string(text)

	fmt.println(text)
}
