using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
//using Newtonsoft.Json.Linq;
using TsMap;

public class NodeList {
  public static void Main (string[] argv) {
    if (argv.Length < 3) {
      Console.WriteLine("Usage:");
      Console.WriteLine("  mono NodeList.exe <ats-path> <in-path> <out-path>");
      Console.WriteLine("ats-path: path to 'American Truck Simulator' Steam directory");
      Console.WriteLine("in-path:  path to mileage-targets CSV output file");
      Console.WriteLine("out-path: path to result file");
      Environment.Exit(1);
    }
    string atsPath = argv[0];
    string inPath  = argv[1];
    string outPath = argv[2];

    var mapper = new TsMapper( atsPath, new List<Mod>() );
    mapper.Parse();
    //mapper.ExportCities(0, ".");

    // Read mileage-targets CSV output
    var uids = new List<ulong>();
    using( var reader = new StreamReader(inPath) ) {
      while (! reader.EndOfStream) {
        string[] cols = reader.ReadLine().Split(',');
        if (cols.Length < 7 || cols[6].Equals("")) { continue; }
        try {
          uids.Add( Convert.ToUInt64(cols[6]) );
          //Console.WriteLine($"Found uid: {cols[6]}");
        }
        catch (Exception e) {
          // Usual reason: header line, nothing to worry about
          //Console.WriteLine($"Skipped entry: {cols[0]}");
        }
      }
    }

/*
    // Output as JSON
    JArray nodesJArr = new JArray();
    foreach (ulong uid in uids) {
      TsNode node = mapper.GetNodeByUid(uid);
      if (node == null) {
        // Usual reason: node is in future DLC, nothing to worry about
        //Console.WriteLine($"Failed to find node: {uid}");
        continue;
      }
      nodesJArr.Add( JObject.FromObject(node) );
    }
    File.WriteAllText(outPath, nodesJArr.ToString());
*/

    // Output as CSV
    var builder = new StringBuilder( 48 * uids.Count );
    uids.Sort();
    foreach (ulong uid in uids) {
      TsNode node = mapper.GetNodeByUid(uid);
      if (node == null) { continue; }
      builder.Append(uid);
      builder.Append(',');
      builder.Append(node.X);
      builder.Append(',');
      builder.Append(node.Z);
      builder.Append("\n");
    }
    File.WriteAllText(outPath, builder.ToString());

    Console.WriteLine("Success!");
  }
}
