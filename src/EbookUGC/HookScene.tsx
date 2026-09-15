import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { loadFont, TheBoldFont } from "../load-font";

loadFont();

const Line: React.FC<{ text: string; delay: number; size: number; color?: string }> = ({
  text,
  delay,
  size,
  color = "#f5ead3",
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 200 },
  });
  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const y = interpolate(progress, [0, 1], [26, 0]);
  const scale = interpolate(progress, [0, 1], [0.92, 1]);

  return (
    <div
      style={{
        fontFamily: TheBoldFont,
        fontSize: size,
        color,
        lineHeight: 1.12,
        textAlign: "center",
        opacity,
        transform: `translateY(${y}px) scale(${scale})`,
      }}
    >
      {text}
    </div>
  );
};

export const HookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const pulse = interpolate(frame % 40, [0, 20, 40], [1, 1.015, 1]);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0c0906",
        justifyContent: "center",
        alignItems: "center",
        padding: "0 70px",
      }}
    >
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(212,175,106,0.14) 0%, rgba(0,0,0,0) 62%)",
        }}
      />
      <div style={{ transform: `scale(${pulse})` }}>
        <Line text="¿VAS A EMPEZAR EN BIENES RAÍCES" delay={0} size={62} />
        <div style={{ height: 14 }} />
        <Line text="Y NO SABES POR DÓNDE ARRANCAR?" delay={10} size={62} color="#d4af6a" />
      </div>
    </AbsoluteFill>
  );
};
