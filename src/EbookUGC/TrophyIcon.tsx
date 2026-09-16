import React from "react";

export const TrophyIcon: React.FC<{
  size: number;
  color?: string;
  style?: React.CSSProperties;
}> = ({ size, color = "#d4af6a", style }) => (
  <svg width={size} height={size} viewBox="0 0 64 64" fill="none" style={style}>
    <path
      d="M18 6h28v8a14 14 0 0 1-28 0V6Z"
      fill={color}
    />
    <path
      d="M18 9H8a9 9 0 0 0 9 9"
      stroke={color}
      strokeWidth={3.5}
      fill="none"
      strokeLinecap="round"
    />
    <path
      d="M46 9h10a9 9 0 0 1-9 9"
      stroke={color}
      strokeWidth={3.5}
      fill="none"
      strokeLinecap="round"
    />
    <rect x="29" y="27" width="6" height="13" fill={color} />
    <rect x="19" y="40" width="26" height="6" rx="2.5" fill={color} />
    <rect x="14" y="46" width="36" height="7" rx="3.5" fill={color} />
  </svg>
);
