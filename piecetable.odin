package ptable

import "core:fmt"
import "core:os"
import "core:strings"

// source 0 is the original file
Piece :: struct {
	start, length, source: int,
}

Piece_Table :: struct {
	buffer: [dynamic]string,
	pieces: [dynamic]Piece,
}

// initialiates an empty piece table that can be populated later
init :: proc() -> Piece_Table {
	return Piece_Table{buffer = make([dynamic]string), pieces = make([dynamic]Piece)}
}

// load piece table from filename
from_filename :: proc(filename: string) -> (pt: Piece_Table, success: bool) {
	contents: []byte
	contents, success = os.read_entire_file_from_filename(filename)
	if !success {
		return
	}

	buffer := make([dynamic]string)
	append(&buffer, string(contents))

	pieces := make([dynamic]Piece)
	append(&pieces, Piece{start = 0, length = len(buffer[0]), source = 0})

	return Piece_Table{buffer = buffer, pieces = pieces}, true
}

// deallocate piece table
delete :: proc(pt: Piece_Table) {
	delete_dynamic_array(pt.buffer)
	delete_dynamic_array(pt.pieces)
}

// insert string at index (counting from str[0])
insert :: proc(pt: ^Piece_Table, s: string, idx: int) {
	if len(s) == 0 do return

	append(&pt.buffer, s)
	new_piece := Piece {
		start  = 0,
		length = len(s),
		source = len(pt.buffer) - 1,
	}

	left, right: Piece
	curr_idx, pos: int
	for piece, i in pt.pieces {
		if idx >= curr_idx && idx <= curr_idx + piece.length {
			ordered_remove(&pt.pieces, i)

			left = piece
			left.length = idx - curr_idx

			pos = i
			if (left.length != 0) {
				inject_at(&pt.pieces, i, left)
				pos += 1
			}

			inject_at(&pt.pieces, pos, new_piece)
			pos += 1

			right = piece
			right.start += left.length
			right.length -= left.length

			if (right.length != 0) do inject_at(&pt.pieces, pos, right)
		}

		curr_idx += piece.length
	}
}

// returns the length of the string represented by the piece table
length :: proc(pt: Piece_Table) -> int {
	size: int
	for piece in pt.pieces {
		size += piece.length
	}

	return size
}

// returns an allocated string with the decoded piece table string
get_text :: proc(pt: Piece_Table) -> string {
	strb: strings.Builder
	strings.builder_init_len(&strb, length(pt))
	for piece in pt.pieces {
		strings.write_string(
			&strb,
			pt.buffer[piece.source][piece.start:piece.start + piece.length],
		)
	}

	return strings.to_string(strb)
}

// returns an allocated string with the line on the corresponding line number (starting from 0)
get_line :: proc(pt: Piece_Table, linenum: int) -> (row: string, overflow: bool) {
	strb: strings.Builder
	strings.builder_init(&strb)
	line, line_start: int

	for piece, piece_no in pt.pieces {
		str := string(pt.buffer[piece.source][piece.start:piece.start + piece.length])
		for c, i in str {
			if line == linenum {
				strings.write_rune(&strb, c)
			}

			if c == '\n' {
				line += 1
				line_start = i + 1
			}
		}
	}

	if linenum > line {
		return {}, true
	}

	return strings.to_string(strb), false
}

// remove string starting from idx up until idx + length
remove :: proc(pt: ^Piece_Table, idx, length: int) {
	unimplemented()
}
