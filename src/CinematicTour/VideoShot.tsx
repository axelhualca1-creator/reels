import React from "react";
import { AbsoluteFill, OffthreadVideo, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

export const VideoShot: React.FC<{
  src: string;
  durationInFrames: number;
  trimBeforeSeconds: number;
  grade?: string;
  vignette?: string;
  // Simulated truck/pan across a horizontal clip cropped to vertical, by
  // animating which part of the frame `object-position` reveals.
  panFrom?: number; // 0-100, % horizontal position at start
  panTo?: number; // 0-100, % horizontal position at end
  playbackRate?: number;
  entryBlurFrames?: number;
  exitBlurFrames?: number;
  blurAmount?: number;
}> = ({
  src,
  durationInFrames,
  trimBeforeSeconds,
  grade = "none",
  vignette,
  panFrom,
  panTo,
  playbackRate = 1,
  entryBlurFrames = 8,
  exitBlurFrames = 8,
  blurAmount = 14,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

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
  const blur = Math.max(blurIn, blurOut);
  const filter = blur > 0 ? `${grade} blur(${blur}px)` : grade;

  const objectPosition =
    panFrom !== undefined && panTo !== undefined
      ? `${interpolate(frame, [0, durationInFrames], [panFrom, panTo], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        })}% center`
      : "center center";

  return (
    <AbsoluteFill style={{ overflow: "hidden", backgroundColor: "#000" }}>
      <OffthreadVideo
        src={src}
        trimBefore={Math.round(trimBeforeSeconds * fps)}
        trimAfter={Math.round(trimBeforeSeconds * fps) + durationInFrames * playbackRate}
        playbackRate={playbackRate}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          objectPosition,
          filter,
        }}
      />
      {vignette ? (
        <AbsoluteFill style={{ background: vignette, pointerEvents: "none" }} />
      ) : null}
    </AbsoluteFill>
  );
};
