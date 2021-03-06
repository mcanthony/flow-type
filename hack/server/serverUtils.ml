(**
 * Copyright (c) 2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)

let shutdown_client (_ic, oc) =
  let cli = Unix.descr_of_out_channel oc in
  try
    Unix.shutdown cli Unix.SHUTDOWN_ALL;
    close_out oc
  with _ -> ()

type connection_state =
  | Connection_ok
  | Build_id_mismatch

let msg_to_channel oc msg =
  Marshal.to_channel oc msg [];
  flush oc

type file_input =
  | FileName of string
  | FileContent of string

let die_nicely genv =
  HackEventLogger.killed ();
  Printf.printf "Status: Error\n";
  Printf.printf "Sent KILL command by client. Dying.\n";
  (match genv.ServerEnv.dfind with
  | Some handle -> Unix.kill (DfindLib.pid handle) Sys.sigterm;
  | None -> ()
  );
  exit 0
