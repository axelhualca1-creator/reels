import React from "react";
import { AbsoluteFill, Easing, Img, interpolate, useCurrentFrame } from "remotion";

export type Transform = {
  scale: number;
  x: number; // % of frame width
  y: number; // % of frame height
  rotate?: number; // degrees
};

const DEFAULT_EASING = Easing.out(Easing.cubic);

export const Shot: React.FC<{
  src: string;
  durationInFrames: number;
  from: Transform;
  to: Transform;
  focalPoint?: string;
  grade?: string;
  vignette?: string;
  easing?: (t: number) => number;
  entryBlur?: number; // px of blur at frame 0, ramping to 0
  entryBlurFrames?: number;
  exitBlur?: number; // px of blur ramping up at the end (whip-pan out)
  exitBlurFrames?: number;
}> = ({
  src,
  durationInFrames,
  from,
  to,
  focalPoint = "center center",
  grade = "none",
  vignette,
  easing = DEFAULT_EASING,
  entryBlur = 0,
  entryBlurFrames = 12,
  exitBlur = 0,
  exitBlurFrames = 10,
}) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [0, durationInFrames], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing,
  });

  const scale = from.scale + (to.scale - from.scale) * progress;
  const x = from.x + (to.x - from.x) * progress;
  const y = from.y + (to.y - from.y) * progress;
  const rotate = (from.rotate ?? 0) + ((to.rotate ?? 0) - (from.rotate ?? 0)) * progress;

  const blurIn = interpolate(frame, [0, entryBlurFrames], [entryBlur, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const blurOut = interpolate(
    frame,
    [durationInFrames - exitBlurFrames, durationInFrames],
    [0, exitBlur],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );
  const blur = Math.max(blurIn, blurOut);

  return (
    <AbsoluteFill style={{ overflow: "hidden", backgroundColor: "#000" }}>
      <AbsoluteFill
        style={{
          transform: `scale(${scale}) translate(${x}%, ${y}%) rotate(${rotate}deg)`,
        }}
      >
        <Img
          src={src}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: focalPoint,
            filter: blur > 0 ? `${grade} blur(${blur}px)` : grade,
          }}
        />
      </AbsoluteFill>
      {vignette ? (
        <AbsoluteFill style={{ background: vignette, pointerEvents: "none" }} />
      ) : null}
    </AbsoluteFill>
  );
};
