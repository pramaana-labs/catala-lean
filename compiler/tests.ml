let () =
  let open Alcotest in
  run "Catala Compiler Tests"
    ([ ( "Iota-reduction",
        [
          test_case "#1" `Quick Shared_ast.Optimizations.test_iota_reduction_1;
          test_case "#2" `Quick Shared_ast.Optimizations.test_iota_reduction_2;
        ] ) ]
    @ Lean4_desugared_test.suite)
