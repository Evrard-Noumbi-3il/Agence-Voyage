export function useThemeColor(
  props: { light?: string; dark?: string },
  colorName: string
) {
  // Pour l'instant, on retourne juste une couleur noire ou la prop fournie
  return props.light || '#000000';
}