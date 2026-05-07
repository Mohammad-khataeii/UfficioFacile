export function JsonEditor({
  name,
  defaultValue,
  rows = 12,
}: {
  name: string;
  defaultValue: unknown;
  rows?: number;
}) {
  return (
    <textarea
      name={name}
      rows={rows}
      defaultValue={JSON.stringify(defaultValue ?? {}, null, 2)}
      className="font-mono text-xs"
    />
  );
}
