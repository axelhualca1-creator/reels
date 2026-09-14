import React from "react";
import { AbsoluteFill, Easing, Img, interpolate, useCurrentFrame } from "remotion";

/**
 * Poor-man's 2.5D parallax for a single still photo: the SAME image is drawn
 * twice, once as a soft/dark "background" plane and once as a sharp
 * "foreground" plane revealed only near one edge (mask). The foreground
 * plane scales up faster than the background as the shot progresses, which
 * mimics how nearer objects grow faster than distant ones during a real
 * dolly-in - giving a sense of depth without any actual depth estimation.
 */
export const ParallaxShot: React.FC<{
  src: string;
  durationInFrames: number;
  focalPoint?: string;
  grade?: string;
  vignette?: string;
  maskEdge?: "bottom" | "top";
  foregroundCoverage?: number; // 0-1, fraction of frame the fg plane fully covers
  bgScale: [number, number];
  fgScale: [number, number];
  entryBlurFrames?: number;
  exitBlurFrames?: number;
  blurAmount?: number;
}> = ({
  src,
  durationInFrames,
  focalPoint = "center center",
  grade = "none",
  vignette,
  maskEdge = "bottom",
  foregroundCoverage = 0.42,
  bgScale,
  fgScale,
  entryBlurFrames = 10,
  exitBlurFrames = 10,
  blurAmount = 0,
}) => {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [0, durationInFrames], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  const bg = bgScale[0] + (bgScale[1] - bgScale[0]) * progress;
  const fg = fgScale[0] + (fgScale[1] - fgScale[0]) * progress;

  const blurIn = interpolate(frame, [0, entryBlurFrames], [blurAmount, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const blurOut = interpolate(
    frame,
    [durationInFrames - exitBlurFrames, durationInFrames],
    [0, blurAmount],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );
  const cutBlur = Math.max(blurIn, blurOut);

  const solidStop = Math.round(foregroundCoverage * 100);
  const featherStop = Math.min(100, solidStop + 32);
  const gradientDirection = maskEdge === "bottom" ? "to top" : "to bottom";
  const maskImage = `linear-gradient(${gradientDirection}, black 0%, black ${solidStop}%, transparent ${featherStop}%)`;

  return (
    <AbsoluteFill style={{ overflow: "hidden", backgroundColor: "#000" }}>
      {/* Background plane: distant, softer, moves slower */}
      <AbsoluteFill style={{ transform: `scale(${bg})` }}>
        <Img
          src={src}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: focalPoint,
            filter: `${grade} blur(${2.5 + cutBlur}px) brightness(0.92)`,
          }}
        />
      </AbsoluteFill>
      {/* Foreground plane: near, sharp, moves faster - masked to one edge */}
      <AbsoluteFill
        style={{
          transform: `scale(${fg})`,
          WebkitMaskImage: maskImage,
          maskImage,
        }}
      >
        <Img
          src={src}
          style={{
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: focalPoint,
            filter: cutBlur > 0 ? `${grade} blur(${cutBlur}px)` : grade,
          }}
        />
      </AbsoluteFill>
      {vignette ? (
        <AbsoluteFill style={{ background: vignette, pointerEvents: "none" }} />
      ) : null}
    </AbsoluteFill>
  );
};
