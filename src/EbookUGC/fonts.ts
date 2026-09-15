import { loadFont as loadPlayfair } from "@remotion/google-fonts/PlayfairDisplay";

export const loadFonts = () =>
  loadPlayfair("normal", { weights: ["500", "600", "700"], subsets: ["latin"] });
