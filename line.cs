using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length != 2)
        {
            Console.Error.WriteLine("Usage: LINES <file|CLIP:> <line-number>");
            return 1;
        }

        int optionBase = 0;
        string optionBaseValue = Environment.GetEnvironmentVariable("OptionBase");

        if (optionBaseValue != null &&
            (!int.TryParse(optionBaseValue, out optionBase) ||
             (optionBase != 0 && optionBase != 1)))
        {
            Console.Error.WriteLine("OptionBase must be 0 or 1.");
            return 1;
        }

        string numberText = args[1];
        bool isNegative = numberText.StartsWith("-", StringComparison.Ordinal);
        string magnitudeText = isNegative
            ? numberText.Substring(1)
            : numberText;

        if (!long.TryParse(magnitudeText, out long requestedNumber) ||
            requestedNumber < 0)
        {
            Console.Error.WriteLine(
                "The line number must be a non-negative integer, optionally preceded by '-'.");
            return 1;
        }

        try
        {
            string[] lines;

            if (string.Equals(args[0], "CLIP:", StringComparison.OrdinalIgnoreCase))
            {
                if (!Clipboard.ContainsText())
                {
                    Console.Error.WriteLine("The clipboard does not contain text.");
                    return 1;
                }

                string clipboardText =
                    Clipboard.GetText(TextDataFormat.UnicodeText);

                lines = ReadLines(clipboardText);
            }
            else
            {
                var result = new List<string>();

                using (var reader = new StreamReader(
                    args[0],
                    Encoding.Default,
                    detectEncodingFromByteOrderMarks: true))
                {
                    string line;

                    while ((line = reader.ReadLine()) != null)
                        result.Add(line);
                }

                lines = result.ToArray();
            }

            long index = isNegative
                ? (long)lines.Length - 1 - requestedNumber
                : requestedNumber - optionBase;

            if (index < 0 || index >= lines.Length)
                Console.WriteLine("EOF");
            else
                Console.WriteLine(lines[(int)index]);

            return 0;
        }
        catch (Exception ex) when (
            ex is IOException ||
            ex is UnauthorizedAccessException ||
            ex is ArgumentException ||
            ex is NotSupportedException ||
            ex is ExternalException)
        {
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
    }

    private static string[] ReadLines(string text)
    {
        var lines = new List<string>();

        using (var reader = new StringReader(text))
        {
            string line;

            while ((line = reader.ReadLine()) != null)
                lines.Add(line);
        }

        return lines.ToArray();
    }
}
