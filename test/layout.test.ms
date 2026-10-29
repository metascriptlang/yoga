// Flexbox layout scenarios with hand-computed expected geometry.

import {
	yogaNode,
	yogaLeaf,
	freeYogaNode,
	layoutTree,
	calculateLayout,
	setStyle,
	layoutPass,
	freeLayoutTree,
	layoutPassAt,
	freeLayoutTreeAt,
	layoutGetChildren,
	layoutGetStyle,
	layoutGetLastStyle,
	layoutSetLastStyle,
	layoutGetYg,
	layoutSetYg,
	layoutSetFrame,
	FlexStyle,
	YGNode,
} from "../src/index";
import { yogaCountStart, yogaLiveNodes } from "./yogaCount.h";
@compile("./yogaCount.cpp", "-std=c++20");

function near(actual: float32, expected: float32): boolean {
	const d = actual - expected;
	if (d < 0.01 && d > -0.01) return true;
	console.log("expected " + expected.toString() + " got " + actual.toString());
	return false;
}

function liveNodes(): int32 {
	yogaCountStart();
	return yogaLiveNodes();
}

test "column flex grow" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ height: 50.0 }),
	]);
	root.layoutTree(400.0, 300.0);
	assert near(root.children[0].layout.height, 250.0);
	assert near(root.children[1].layout.top, 250.0);
	assert near(root.children[1].layout.height, 50.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "row justify center" {
	const live = liveNodes();
	const style: FlexStyle = {
		flexDirection: "row",
		justifyContent: "center",
		alignItems: "center",
		width: 300.0,
		height: 100.0,
	};
	const root = yogaNode(style, [
		yogaLeaf({ width: 50.0, height: 40.0 }),
		yogaLeaf({ width: 50.0, height: 40.0 }),
	]);
	root.layoutTree(300.0, 100.0);
	assert near(root.children[0].layout.left, 100.0);
	assert near(root.children[1].layout.left, 150.0);
	assert near(root.children[0].layout.top, 30.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "row right to left" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "row", width: 300.0, height: 100.0 }, [
		yogaLeaf({ width: 50.0 }),
		yogaLeaf({ width: 30.0 }),
	]);
	root.calculateLayout(300.0, 100.0, "rtl");
	assert near(root.children[0].layout.left, 250.0);
	assert near(root.children[1].layout.left, 220.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "reverse row space between" {
	const live = liveNodes();
	const style: FlexStyle = {
		flexDirection: "row-reverse",
		justifyContent: "space-between",
		alignItems: "flex-end",
		width: 200.0,
		height: 100.0,
	};
	const root = yogaNode(style, [
		yogaLeaf({ width: 50.0, height: 30.0 }),
		yogaLeaf({ width: 50.0, height: 40.0 }),
	]);
	root.layoutTree(200.0, 100.0);
	assert near(root.children[0].layout.left, 150.0);
	assert near(root.children[1].layout.left, 0.0);
	assert near(root.children[0].layout.top, 70.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "wrap skips display none" {
	const live = liveNodes();
	const style: FlexStyle = {
		flexDirection: "row",
		flexWrap: "wrap",
		alignContent: "flex-start",
		width: 100.0,
		height: 100.0,
	};
	const root = yogaNode(style, [
		yogaLeaf({ width: 40.0, height: 20.0 }),
		yogaLeaf({ width: 40.0, height: 20.0, display: "none" }),
		yogaLeaf({ width: 40.0, height: 20.0 }),
		yogaLeaf({ width: 40.0, height: 20.0 }),
	]);
	root.layoutTree(100.0, 100.0);
	assert near(root.children[2].layout.left, 40.0);
	assert near(root.children[3].layout.left, 0.0);
	assert near(root.children[3].layout.top, 20.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "padding and margin" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 200.0, height: 200.0, padding: 10.0 }, [
		yogaLeaf({ flexGrow: 1.0, margin: 5.0 }),
	]);
	root.layoutTree(200.0, 200.0);
	assert near(root.children[0].layout.left, 15.0);
	assert near(root.children[0].layout.top, 15.0);
	assert near(root.children[0].layout.width, 170.0);
	assert near(root.children[0].layout.height, 170.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "absolute position" {
	const live = liveNodes();
	const root = yogaNode({ width: 300.0, height: 300.0 }, [
		yogaLeaf({ position: "absolute", left: 20.0, top: 30.0, width: 50.0, height: 60.0 }),
	]);
	root.layoutTree(300.0, 300.0);
	assert near(root.children[0].layout.left, 20.0);
	assert near(root.children[0].layout.top, 30.0);
	assert near(root.children[0].layout.width, 50.0);
	assert near(root.children[0].layout.height, 60.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "nested row in column" {
	const live = liveNodes();
	const row = yogaNode({ flexDirection: "row", height: 60.0, gap: 10.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ flexGrow: 1.0 }),
	]);
	const root = yogaNode({ flexDirection: "column", width: 210.0, height: 200.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		row,
	]);
	root.layoutTree(210.0, 200.0);
	assert near(row.layout.top, 140.0);
	assert near(row.children[0].layout.width, 100.0);
	assert near(row.children[1].layout.left, 110.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "relayout after set style" {
	const live = liveNodes();
	const child = yogaLeaf({ height: 50.0 });
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [child]);
	root.layoutTree(100.0, 200.0);
	assert near(child.layout.height, 50.0);
	child.setStyle({ height: 80.0 });
	root.layoutTree(100.0, 200.0);
	assert near(child.layout.height, 80.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

// Generic layoutPass (sync.ms protocol) with YogaNode as consumer — same
// geometry as columnFlexGrow but driven through the cross-module generic.
test "generic layout pass on yoga node" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ flexGrow: 1.0 }),
		yogaLeaf({ height: 50.0 }),
	]);
	layoutPass(root, 400.0, 300.0);
	assert near(root.children[0].layout.height, 250.0);
	assert near(root.children[1].layout.top, 250.0);
	assert near(root.layout.width, 400.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

export interface HostBox {
	flex: FlexStyle | null;
	lastFlex: FlexStyle | null;
	yg: Ptr<YGNode> | null;
	children: HostBox[];
	x: float32;
	y: float32;
	w: float32;
	h: float32;
}

export function layoutGetChildren(this n: HostBox): HostBox[] { return n.children; }
export function layoutGetStyle(this n: HostBox): FlexStyle | null { return n.flex; }
export function layoutGetLastStyle(this n: HostBox): FlexStyle | null { return n.lastFlex; }
export function layoutSetLastStyle(this n: HostBox, s: FlexStyle | null): void { n.lastFlex = s; }
export function layoutGetYg(this n: HostBox): Ptr<YGNode> | null { return n.yg; }
export function layoutSetYg(this n: HostBox, yg: Ptr<YGNode> | null): void { n.yg = yg; }
export function layoutSetFrame(
	this n: HostBox,
	x: float32,
	y: float32,
	w: float32,
	h: float32,
): void {
	n.x = x;
	n.y = y;
	n.w = w;
	n.h = h;
}

function hostBox(flex: FlexStyle, children: HostBox[]): HostBox {
	return {
		flex: flex,
		lastFlex: null,
		yg: null,
		children: children,
		x: 0.0,
		y: 0.0,
		w: 0.0,
		h: 0.0,
	};
}

test "generic layout pass on host tree" {
	const live = liveNodes();
	const grow = hostBox({ flexGrow: 1.0 }, []);
	const fixed = hostBox({ height: 50.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 400.0, height: 300.0 }, [grow, fixed]);
	layoutPass(root, 400.0, 300.0);
	assert near(grow.h, 250.0);
	assert near(fixed.y, 250.0);
	assert near(root.w, 400.0);
	freeLayoutTree(root);
	assert root.yg === null && grow.yg === null;
	assert liveNodes() == live;
}

test "null style releases yoga node" {
	const live = liveNodes();
	const leaf = hostBox({ height: 20.0 }, []);
	const child = hostBox({ height: 50.0 }, [leaf]);
	const other = hostBox({ height: 30.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 100.0, height: 200.0 }, [child, other]);
	layoutPass(root, 100.0, 200.0);
	child.flex = null;
	layoutPass(root, 100.0, 200.0);
	assert child.yg === null && leaf.yg === null;
	assert near(other.y, 0.0);
	freeLayoutTree(root);
	assert liveNodes() == live;
}

test "removed child freed by host" {
	const live = liveNodes();
	const late = hostBox({ height: 50.0 }, [hostBox({ height: 20.0 }, [])]);
	const early = hostBox({ height: 10.0 }, []);
	const other = hostBox({ height: 30.0 }, []);
	const column: FlexStyle = { flexDirection: "column", width: 100.0, height: 200.0 };
	const root = hostBox(column, [late, early, other]);
	layoutPass(root, 100.0, 200.0);
	root.children = [early, other];
	layoutPass(root, 100.0, 200.0);
	freeLayoutTree(late);
	assert near(other.y, 10.0);
	root.children = [other];
	freeLayoutTree(early);
	layoutPass(root, 100.0, 200.0);
	assert near(other.y, 0.0);
	freeLayoutTree(root);
	assert liveNodes() == live;
}

test "restyled child rejoins layout" {
	const live = liveNodes();
	const child = hostBox({ height: 50.0 }, [hostBox({ height: 20.0 }, [])]);
	const other = hostBox({ height: 30.0 }, []);
	const root = hostBox({ flexDirection: "column", width: 100.0, height: 200.0 }, [child, other]);
	layoutPass(root, 100.0, 200.0);
	child.flex = null;
	layoutPass(root, 100.0, 200.0);
	child.flex = { height: 40.0 };
	layoutPass(root, 100.0, 200.0);
	assert near(child.h, 40.0);
	assert near(child.children[0].h, 20.0);
	assert near(other.y, 40.0);
	freeLayoutTree(root);
	assert liveNodes() == live;
}

test "percent width height" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 400.0, height: 300.0 }, [
		yogaLeaf({ width: "50%", height: "25%" }),
	]);
	root.layoutTree(400.0, 300.0);
	assert near(root.children[0].layout.width, 200.0);
	assert near(root.children[0].layout.height, 75.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "auto margin centers" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 300.0, height: 100.0 }, [
		yogaLeaf({ width: 100.0, height: 40.0, marginLeft: "auto", marginRight: "auto" }),
	]);
	root.layoutTree(300.0, 100.0);
	assert near(root.children[0].layout.left, 100.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "flex basis percent" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "row", width: 200.0, height: 50.0 }, [
		yogaLeaf({ flexBasis: "25%" }),
		yogaLeaf({ flexGrow: 1.0 }),
	]);
	root.layoutTree(200.0, 50.0);
	assert near(root.children[0].layout.width, 50.0);
	assert near(root.children[1].layout.left, 50.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "min max percent clamp" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "row", width: 400.0, height: 50.0 }, [
		yogaLeaf({ flexGrow: 1.0, maxWidth: "25%" }),
		yogaLeaf({ width: 30.0, minWidth: "20%" }),
	]);
	root.layoutTree(400.0, 50.0);
	assert near(root.children[0].layout.width, 100.0);
	assert near(root.children[1].layout.width, 80.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "min max height strings" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [
		yogaLeaf({ flexGrow: 1.0, maxHeight: "30" }),
		yogaLeaf({ height: 10.0, minHeight: "25%" }),
	]);
	root.layoutTree(100.0, 200.0);
	assert near(root.children[0].layout.height, 30.0);
	assert near(root.children[1].layout.height, 50.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "position and gap strings" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "row", width: 200.0, height: 100.0, columnGap: "10" }, [
		yogaLeaf({ width: 50.0 }),
		yogaLeaf({ width: 50.0 }),
		yogaLeaf({ position: "absolute", left: "10%", top: "20%", width: 10.0, height: 10.0 }),
	]);
	root.layoutTree(200.0, 100.0);
	assert near(root.children[1].layout.left, 60.0);
	assert near(root.children[2].layout.left, 20.0);
	assert near(root.children[2].layout.top, 20.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "numeric string is points" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "row", width: 300.0, height: 50.0 }, [
		yogaLeaf({ width: "120" }),
	]);
	root.layoutTree(300.0, 50.0);
	assert near(root.children[0].layout.width, 120.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "percent edges" {
	const live = liveNodes();
	const style: FlexStyle = {
		flexDirection: "column",
		width: 200.0,
		height: 100.0,
		padding: "10%",
	};
	const root = yogaNode(style, [
		yogaLeaf({ flexGrow: 1.0, marginLeft: "5%" }),
	]);
	root.layoutTree(200.0, 100.0);
	// padding 10% of root width (200) = 20; margin % resolves against the
	// parent's CONTENT width (200 - 40 = 160), so 5% = 8 — yoga semantics.
	assert near(root.children[0].layout.left, 28.0);
	assert near(root.children[0].layout.width, 152.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "relayout to percent" {
	const live = liveNodes();
	const child = yogaLeaf({ height: 50.0 });
	const root = yogaNode({ flexDirection: "column", width: 100.0, height: 200.0 }, [child]);
	root.layoutTree(100.0, 200.0);
	assert near(child.layout.height, 50.0);
	child.setStyle({ height: "40%" });
	root.layoutTree(100.0, 200.0);
	assert near(child.layout.height, 80.0);
	root.freeYogaNode();
	assert liveNodes() == live;
}

export interface TableRow {
	flex: FlexStyle | null;
	lastFlex: FlexStyle | null;
	yg: Ptr<YGNode> | null;
	kids: int32[];
	y: float32;
	h: float32;
}

export class BoxTable {
	rows: TableRow[] = [];
}

export struct BoxRef {
	table: BoxTable;
	row: int32;
}

function tableRow(t: BoxTable, flex: FlexStyle, kids: int32[]): BoxRef {
	t.rows.push({ flex: flex, lastFlex: null, yg: null, kids: kids, y: 0.0, h: 0.0 });
	return { table: t, row: (t.rows.length - 1) as int32 };
}

export function layoutChildCount(this n: BoxRef): int32 { return n.table.rows[n.row].kids.length as int32; }
export function layoutChildAt(this n: BoxRef, i: int32): BoxRef { return { table: n.table, row: n.table.rows[n.row].kids[i] }; }
export function layoutGetStyle(this n: BoxRef): FlexStyle | null { return n.table.rows[n.row].flex; }
export function layoutGetLastStyle(this n: BoxRef): FlexStyle | null { return n.table.rows[n.row].lastFlex; }
export function layoutSetLastStyle(this n: BoxRef, s: FlexStyle | null): void { n.table.rows[n.row].lastFlex = s; }
export function layoutGetYg(this n: BoxRef): Ptr<YGNode> | null { return n.table.rows[n.row].yg; }
export function layoutSetYg(this n: BoxRef, yg: Ptr<YGNode> | null): void { n.table.rows[n.row].yg = yg; }
export function layoutSetFrame(this n: BoxRef, x: float32, y: float32, w: float32, h: float32): void {
	const r = n.table.rows[n.row];
	r.y = y;
	r.h = h;
}

test "indexed layout pass on a table-backed tree" {
	const live = liveNodes();
	const t = new BoxTable();
	const grow = tableRow(t, { flexGrow: 1.0 }, []);
	const leaf = tableRow(t, { height: 20.0 }, []);
	const fixed = tableRow(t, { height: 50.0 }, [leaf.row]);
	const root = tableRow(t, { flexDirection: "column", width: 400.0, height: 300.0 }, [grow.row, fixed.row]);
	layoutPassAt(root, 400.0, 300.0);
	assert near(t.rows[grow.row].h, 250.0);
	assert near(t.rows[fixed.row].y, 250.0);
	t.rows[fixed.row].flex = null;
	layoutPassAt(root, 400.0, 300.0);
	assert t.rows[fixed.row].yg === null && t.rows[leaf.row].yg === null;
	assert near(t.rows[grow.row].h, 300.0);
	freeLayoutTreeAt(root);
	assert t.rows[root.row].yg === null && t.rows[grow.row].yg === null;
	assert liveNodes() == live;
}

test "point scale rounds to device pixels and follows a scale change" {
	const live = liveNodes();
	const root = yogaNode({ flexDirection: "column", width: 100.0 }, [
		yogaLeaf({ height: 17.5 }), yogaLeaf({ height: 17.5 }), yogaLeaf({ height: 17.5 }), yogaLeaf({ height: 17.5 }),
	]);
	layoutPass(root, 100.0, 1000.0, "ltr", 2.0);
	assert near(root.children[1].layout.top, 17.5) && near(root.children[3].layout.top, 52.5);
	layoutPass(root, 100.0, 1000.0, "ltr", 1.0);
	assert near(root.children[1].layout.top, 18.0) && near(root.children[3].layout.top, 53.0);
	layoutPass(root, 100.0, 1000.0, "ltr", 2.0);
	assert near(root.children[1].layout.top, 17.5) && near(root.children[3].layout.top, 52.5);
	root.freeYogaNode();
	assert liveNodes() == live;
}

test "indexed layout pass takes the point scale" {
	const live = liveNodes();
	const t = new BoxTable();
	const a = tableRow(t, { height: 17.5 }, []);
	const b = tableRow(t, { height: 17.5 }, []);
	const c = tableRow(t, { height: 17.5 }, []);
	const d = tableRow(t, { height: 17.5 }, []);
	const root = tableRow(t, { flexDirection: "column", width: 100.0 }, [a.row, b.row, c.row, d.row]);
	layoutPassAt(root, 100.0, 1000.0, "ltr", 2.0);
	assert near(t.rows[b.row].y, 17.5) && near(t.rows[d.row].y, 52.5);
	layoutPassAt(root, 100.0, 1000.0, "ltr", 1.0);
	assert near(t.rows[b.row].y, 18.0) && near(t.rows[d.row].y, 53.0);
	freeLayoutTreeAt(root);
	assert liveNodes() == live;
}
