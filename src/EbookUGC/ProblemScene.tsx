import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

const PROBLEMS = [
  "Captar propiedades incompletas",
  "Publicar sin estrategia",
  "Perder clientes por falta de seguimiento",
  "No saber cómo presentar una oferta",
];

const ProblemRow: React.FC<{ text: string; delay: number }> = ({ text, delay }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 200 } });
  const opacity = interpolate(progress, [0, 1], [0, 1]);
  const x = interpolate(progress, [0, 1], [-40, 0]);

  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 18,
        opacity,
        transform: `translateX(${x}px)`,
        marginBottom: 30,
      }}
    >
      <div
        style={{
          width: 40,
          height: 40,
          borderRadius: "50%",
          border: "2px solid #b23b3b",
          color: "#e08787",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontFamily,
          fontWeight: 700,
          fontSize: 20,
          flexShrink: 0,
        }}
      >
        ✕
      </div>
      <div
        style={{
          fontFamily,
          fontWeight: 600,
          fontSize: 33,
          color: "#f0e6d2",
          lineHeight: 1.2,
        }}
      >
        {text}
      </div>
    </div>
  );
};

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const headerProgress = spring({ frame, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill style={{ backgroundColor: "#0c0906", padding: "0 84px", justifyContent: "center" }}>
      <div
        style={{
          fontFamily,
          fontWeight: 700,
          fontStyle: "italic",
          fontSize: 30,
          color: "#d4af6a",
          marginBottom: 48,
          opacity: interpolate(headerProgress, [0, 1], [0, 1]),
        }}
      >
        Empezar sin método puede costarte...
      </div>
      {PROBLEMS.map((p, i) => (
        <ProblemRow key={p} text={p} delay={12 + i * 14} />
      ))}
    </AbsoluteFill>
  );
};
