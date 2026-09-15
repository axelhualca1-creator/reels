import React from "react";
import {
  AbsoluteFill,
  Audio,
  interpolate,
  Sequence,
  staticFile,
  useCurrentFrame,
} from "remotion";
import { z } from "zod";
import { AuthorScene } from "./AuthorScene";
import { ContentsScene } from "./ContentsScene";
import { CTAScene } from "./CTAScene";
import { HookScene } from "./HookScene";
import { ProblemScene } from "./ProblemScene";
import { RevealScene } from "./RevealScene";

export const ebookUgcSchema = z.object({
  authorName: z.string(),
  brokerage: z.string(),
  contact: z.string().optional(),
});

const FPS = 30;
const HOOK_FRAMES = 3 * FPS;
const PROBLEM_FRAMES = 5 * FPS;
const REVEAL_FRAMES = 4 * FPS;
const CONTENTS_FRAMES = 7 * FPS;
const AUTHOR_FRAMES = 4 * FPS;
const CTA_FRAMES = 4 * FPS;

export const ebookUgcDurationInFrames =
  HOOK_FRAMES + PROBLEM_FRAMES + REVEAL_FRAMES + CONTENTS_FRAMES + AUTHOR_FRAMES + CTA_FRAMES;

const FADE_FRAMES = 12;

const FadeWrapper: React.FC<{ durationInFrames: number; children: React.ReactNode }> = ({
  durationInFrames,
  children,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(
    frame,
    [0, FADE_FRAMES, durationInFrames - FADE_FRAMES, durationInFrames],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );

  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

export const EbookUGC: React.FC<z.infer<typeof ebookUgcSchema>> = ({
  authorName,
  brokerage,
  contact,
}) => {
  let cursor = 0;
  const hookFrom = cursor;
  cursor += HOOK_FRAMES;
  const problemFrom = cursor;
  cursor += PROBLEM_FRAMES;
  const revealFrom = cursor;
  cursor += REVEAL_FRAMES;
  const contentsFrom = cursor;
  cursor += CONTENTS_FRAMES;
  const authorFrom = cursor;
  cursor += AUTHOR_FRAMES;
  const ctaFrom = cursor;

  return (
    <AbsoluteFill style={{ backgroundColor: "#0c0906" }}>
      <Audio src={staticFile("audio/bg-music.mp3")} volume={0.55} />

      <Sequence from={hookFrom} durationInFrames={HOOK_FRAMES}>
        <FadeWrapper durationInFrames={HOOK_FRAMES}>
          <HookScene />
        </FadeWrapper>
      </Sequence>
      <Sequence from={hookFrom + 4} durationInFrames={20}>
        <Audio src={staticFile("audio/pop.mp3")} volume={0.7} />
      </Sequence>

      <Sequence from={problemFrom} durationInFrames={PROBLEM_FRAMES}>
        <FadeWrapper durationInFrames={PROBLEM_FRAMES}>
          <ProblemScene />
        </FadeWrapper>
      </Sequence>
      <Sequence from={problemFrom} durationInFrames={20}>
        <Audio src={staticFile("audio/whoosh.mp3")} volume={0.6} />
      </Sequence>

      <Sequence from={revealFrom} durationInFrames={REVEAL_FRAMES}>
        <FadeWrapper durationInFrames={REVEAL_FRAMES}>
          <RevealScene authorName={authorName} />
        </FadeWrapper>
      </Sequence>
      <Sequence from={revealFrom} durationInFrames={20}>
        <Audio src={staticFile("audio/whoosh.mp3")} volume={0.6} />
      </Sequence>

      <Sequence from={contentsFrom} durationInFrames={CONTENTS_FRAMES}>
        <FadeWrapper durationInFrames={CONTENTS_FRAMES}>
          <ContentsScene />
        </FadeWrapper>
      </Sequence>
      <Sequence from={contentsFrom} durationInFrames={20}>
        <Audio src={staticFile("audio/whoosh.mp3")} volume={0.6} />
      </Sequence>

      <Sequence from={authorFrom} durationInFrames={AUTHOR_FRAMES}>
        <FadeWrapper durationInFrames={AUTHOR_FRAMES}>
          <AuthorScene authorName={authorName} brokerage={brokerage} />
        </FadeWrapper>
      </Sequence>
      <Sequence from={authorFrom} durationInFrames={20}>
        <Audio src={staticFile("audio/whoosh.mp3")} volume={0.5} />
      </Sequence>

      <Sequence from={ctaFrom} durationInFrames={CTA_FRAMES}>
        <FadeWrapper durationInFrames={CTA_FRAMES}>
          <CTAScene authorName={authorName} contact={contact} />
        </FadeWrapper>
      </Sequence>
      <Sequence from={ctaFrom} durationInFrames={20}>
        <Audio src={staticFile("audio/whoosh.mp3")} volume={0.6} />
      </Sequence>
    </AbsoluteFill>
  );
};
