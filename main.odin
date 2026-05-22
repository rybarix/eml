package main

import "core:testing"

//
// TOKENIZER
//


Token_Kind :: enum {
	Number,
	Plus, // +
	Star, // *
	Equals, // =
	Invalid,
	Identifier,
	EOF,
}

Position :: struct {
	start:  int, /* offset in source string */
	length: int,
}

Token :: struct {
	kind: Token_Kind,
	pos:  Position,
}

Tokenizer :: struct {
	offset: int, // offset to source string
	source: string, // ptr to source str
}


is_digit :: proc(c: u8) -> bool {
	return '0' <= c && c <= '9'
}


next_token :: proc(t: ^Tokenizer) -> Token {
	if t.offset >= len(t.source) do return Token{.EOF, Position{0, 0}}

	ch := t.source[t.offset]
	kind: Token_Kind
	pos: Position
	switch ch {
	case '=':
		kind = .Equals
		pos = Position{t.offset, 1}
		t.offset += 1
	case '+':
		kind = .Plus
		pos = Position{t.offset, 1}
		t.offset += 1
	case '*':
		kind = .Star
		pos = Position{t.offset, 1}
		t.offset += 1
	case 'a' ..= 'z':
		// We will support only one character variables for simplicity
		kind = .Identifier
		pos = Position{t.offset, 1}
		t.offset += 1
	case '0' ..= '9':
		start := t.offset
		// why we reading numbers, keep going!
		for t.offset < len(t.source) && is_digit(t.source[t.offset]) {
			t.offset += 1
		}

		end := t.offset
		kind = .Number
		pos = Position{start, end - start}
	case:
		kind = .Invalid
		pos = Position{0, 0}

	}

	return Token{kind, pos}
}

@(test)
tokenize_test :: proc(t: ^testing.T) {
	code := "+"
	tokenizer := Tokenizer {
		offset = 0,
		source = code,
	}
	testing.expect(t, next_token(&tokenizer).kind == .Plus)
}

@(test)
tokenize_variable_test :: proc(t: ^testing.T) {
	code := "a=10"

	tokenizer := Tokenizer {
		offset = 0,
		source = code,
	}

	token1 := next_token(&tokenizer)
	testing.expect(t, token1.kind == .Identifier)
	testing.expect(t, token1.pos.start == 0 && token1.pos.length == 1)

	token2 := next_token(&tokenizer)
	testing.expect(t, token2.kind == .Equals)
	testing.expect(t, token2.pos.start == 1 && token2.pos.length == 1)

	token3 := next_token(&tokenizer)
	testing.expect(t, token3.kind == .Number)
	testing.expect(t, token3.pos.start == 2 && token3.pos.length == 2)
}

@(test)
tokenize_number_test :: proc(t: ^testing.T) {
	code := "123+45*1"

	tokenizer := Tokenizer {
		offset = 0,
		source = code,
	}

	token1 := next_token(&tokenizer)
	testing.expect(t, token1.kind == .Number)
	testing.expect(t, token1.pos.start == 0 && token1.pos.length == 3)

	token2 := next_token(&tokenizer)
	testing.expect(t, token2.kind == .Plus)
	testing.expect(t, token2.pos.start == 3 && token2.pos.length == 1)

	token3 := next_token(&tokenizer)
	testing.expect(t, token3.kind == .Number)
	testing.expect(t, token3.pos.start == 4 && token3.pos.length == 2)

	token4 := next_token(&tokenizer)
	testing.expect(t, token4.kind == .Star)
	testing.expect(t, token4.pos.start == 6 && token4.pos.length == 1)

	token5 := next_token(&tokenizer)
	testing.expect(t, token5.kind == .Number)
	testing.expect(t, token5.pos.start == 7 && token5.pos.length == 1)
}


main :: proc() {
	// We don't have much to run...
	// We will use primarily tests for confirming that our code is OK
}
