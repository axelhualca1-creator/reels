import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";

/**
 * A brief warm flash straddling a hard cut, used instead of a plain
 * crossfade at the one emotionally-loaded transition (hero -> closing).
 * Rendered as its own overlapping Sequence, peaking exactly at the cut.
 */
export const FlashCut: React.FC<{ totalFrames: number; peakFrame: number; color?: string }> = ({
  totalFrames,
  peakFrame,
  color = "#fff3d6",
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, peakFrame, totalFrames], [0, 0.85, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: color,
        opacity,
        pointerEvents: "none",
      }}
    />
  );
};
