import React from "react";
import { AbsoluteFill, Img, interpolate, useCurrentFrame } from "remotion";

const FADE_FRAMES = 10;

export const KenBurnsScene: React.FC<{
  src: string;
  durationInFrames: number;
  startScale: number;
  endScale: number;
  focalPoint?: string;
  grade?: string;
  vignette?: string;
  fadeIn?: boolean;
  fadeOut?: boolean;
}> = ({
  src,
  durationInFrames,
  startScale,
  endScale,
  focalPoint = "center center",
  grade = "none",
  vignette,
  fadeIn = true,
  fadeOut = true,
}) => {
  const frame = useCurrentFrame();

  const scale = interpolate(frame, [0, durationInFrames], [startScale, endScale], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const opacityPoints = [0];
  const opacityValues = [fadeIn ? 0 : 1];
  if (fadeIn) {
    opacityPoints.push(FADE_FRAMES);
    opacityValues.push(1);
  }
  const fadeOutStart = durationInFrames - (fadeOut ? FADE_FRAMES : 0);
  if (fadeOutStart > opacityPoints[opacityPoints.length - 1]) {
    opacityPoints.push(fadeOutStart);
    opacityValues.push(1);
  }
  opacityPoints.push(durationInFrames);
  opacityValues.push(fadeOut ? 0 : 1);

  const opacity = interpolate(frame, opacityPoints, opacityValues, {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ opacity, overflow: "hidden", backgroundColor: "#0a0a0a" }}>
      <AbsoluteFill
        style={{
          transform: `scale(${scale})`,
          transformOrigin: focalPoint,
        }}
      >
        <Img
          src={src}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: focalPoint,
            filter: grade,
          }}
        />
      </AbsoluteFill>
      {vignette ? (
        <AbsoluteFill style={{ background: vignette, pointerEvents: "none" }} />
      ) : null}
    </AbsoluteFill>
  );
};
