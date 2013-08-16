let load_ir lexbuf =
  let lex () = IrLexer.next lexbuf in
  let parse  = MenhirLib.Convert.Simplified.traditional2revised IrParser.toplevel in
  let roots, main = parse lex in
    Rt.roots := roots;
    main

let dump_ir main =
  IrPrinter.print_ssa main

let _ =
  let output = ref "-"   in
  let inputs = ref []    in

  Arg.parse (Arg.align [
      "-o", Arg.Set_string output,
        "<file> Output file";

      "-ordered", Arg.Set IrPrinter.ordered,
        " Iterate symbol tables in alphabetical order"
    ]) (fun arg ->
      inputs := arg :: !inputs)
    ("Usage: " ^ (Sys.argv.(0) ^ " [options] <input-file>..."));

  let input_ir =
    Unicode.Std.String.concat u""
      (List.map Io.input_all
        (List.map Io.open_in !inputs)) in

  let main     = load_ir (Lexing.from_string (input_ir :> string)) in
  let out_chan = Io.open_out !output in
    Unicode.Std.output_string out_chan (dump_ir main)